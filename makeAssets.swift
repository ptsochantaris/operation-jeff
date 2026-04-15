import CoreGraphics
import Foundation
import ImageIO

@discardableResult func run(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
    task.standardInput = nil

    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)!
}

private struct FileGroup {
    var files: [FileInfo]
    var totalSize: Int
    let page: Int
    let org: String
    let orgOffset: Int

    mutating func addFile(info: FileInfo) {
        var info = info
        info.pos = totalSize
        files.append(info)
        totalSize += info.size
    }

    func canFit(info: FileInfo) -> Bool {
        info.size <= (8192 - totalSize)
    }

    init(page: Int, org: String, orgOffset: Int) {
        self.page = page
        self.org = org
        self.orgOffset = orgOffset
        files = [FileInfo]()
        totalSize = 0
    }
}

private struct FileInfo {
    let name: String
    let size: Int
    var pos: Int

    var variableName: String {
        name.replacingOccurrences(of: ".", with: "_").components(separatedBy: "/").last!
    }
}

private func getFileSize(_ path: String) -> Int? {
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        if let fileSize = attributes[.size] as? Int {
            return fileSize
        }
    } catch {
        print("Error getting file size for \(path): \(error)")
    }
    return nil
}

private func makeAssets(from filePaths: [String]) {
    var mmu1Files = [FileInfo]()
    var mmu3Files = [FileInfo]()

    for filePath in filePaths where !filePath.contains("loadingScreen.") {
        if let fileSize = getFileSize(filePath) {
            let info = FileInfo(name: filePath, size: fileSize, pos: 0)
            if filePath.contains(".nxp") {
                mmu3Files.append(info)
            } else {
                mmu1Files.append(info)
            }
        }
    }
    mmu1Files = mmu1Files.sorted { $0.size > $1.size }
    mmu3Files = mmu3Files.sorted { $0.size > $1.size }

    var firstPage = 29

    var mmu3Groups = (firstPage ..< 200).map { FileGroup(page: $0, org: "0x6000", orgOffset: 0x6000) }
    for info in mmu3Files {
        if let firstFit = mmu3Groups.firstIndex(where: { $0.canFit(info: info) }) {
            var group = mmu3Groups[firstFit]
            group.addFile(info: info)
            mmu3Groups[firstFit] = group
        }
    }
    mmu3Groups.removeAll { $0.totalSize == 0 }

    if let lastFilled = mmu3Groups.last?.page {
        firstPage = lastFilled + 1
    }

    var mmu1Groups = (firstPage ..< 200).map { FileGroup(page: $0, org: "0x2000", orgOffset: 0x2000) }
    for info in mmu1Files {
        if let firstFit = mmu1Groups.firstIndex(where: { $0.canFit(info: info) }) {
            var group = mmu1Groups[firstFit]
            group.addFile(info: info)
            mmu1Groups[firstFit] = group
        } else if let firstEmpty = mmu1Groups.firstIndex(where: { $0.totalSize == 0 }) {
            var group = mmu1Groups[firstEmpty]
            group.addFile(info: info)
            mmu1Groups.remove(at: firstEmpty)
            mmu1Groups[firstEmpty] = group
        }
    }
    mmu1Groups.removeAll { $0.totalSize == 0 }

    let groups = mmu3Groups + mmu1Groups

    var outputContent = ""
    for group in groups {
        outputContent += """
        ;-------------------------------------------------     

        SECTION PAGE_\(group.page)\n
        """
        for file in group.files {
            outputContent +=
                """
                BINARY "\(file.name)"\n
                """
        }
        outputContent += "\n"
    }

    do {
        try outputContent.write(to: URL(fileURLWithPath: "src/assets.asm"), atomically: true, encoding: .utf8)
        print("assets.asm created")
    } catch {
        print("Error writing to output file: \(error)")
    }

    outputContent = """
    #ifndef __ASSETS_H__
    #define __ASSETS_H__\n
    """
    for group in groups {
        for file in group.files {
            let offset = group.orgOffset + file.pos
            outputContent += """
            #define R_\(file.variableName) { \(offset), \(file.size), \(group.page) }\n
            """
        }
    }
    outputContent += "\n#endif\n"

    do {
        try outputContent.write(to: URL(fileURLWithPath: "src/assets.h"), atomically: true, encoding: .utf8)
        print("assets.h created")
    } catch {
        print("Error writing to output file: \(error)")
    }
}

private func convertHeightMap(at imagePath: String) -> Data {
    guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: imagePath) as CFURL, nil) else {
        fatalError("Could not load image from file: $imagePath)")
    }

    let options = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, options) else {
        fatalError("Could not create image from source")
    }

    let width = image.width
    let height = image.height
    let bitsPerComponent = 8
    let bytesPerRow = width * 4 // 4 bytes per pixel for RGBA
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

    guard let context = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: bitsPerComponent,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: bitmapInfo.rawValue)
    else {
        fatalError("Could not create CGContext")
    }

    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let pixelData = context.data else {
        fatalError("Could not get pixel data")
    }

    let buffer = pixelData.assumingMemoryBound(to: UInt8.self)

    var brightnessBytes = Data()

    for y in 0 ..< height {
        for x in 0 ..< width {
            let byteIndex = 4 * (y * width + x) // 4 bytes per pixel (R, G, B, A)
            let r = buffer[byteIndex]
            brightnessBytes.append(r / 8)
        }
    }
    return brightnessBytes
}

let CONV = "../Gfx2Next/build/gfx2next"
let COMPRESS = "../ZX0/src/zx0"
let ORIG = "resources_original"
let DST = "resources"
let LETTERS = "ABCDEFGHIJKLMNOPQ"
let NUMBERS = "0123456789"
let fm = FileManager.default

do {
    if fm.fileExists(atPath: DST) {
        print("Removing \(DST)")
        try fm.removeItem(atPath: DST)
    }

    print("Creating \(DST)")
    try fm.createDirectory(atPath: DST, withIntermediateDirectories: false)

    let resourceSource = try fm.contentsOfDirectory(atPath: ORIG).filter {
        $0.hasSuffix(".pcm") || $0.hasSuffix(".nxp") || $0.hasSuffix(".spr")
    }
    print("Copying: ", terminator: "")
    for item in resourceSource {
        print(item, terminator: " ")
        try fm.copyItem(atPath: "\(ORIG)/\(item)", toPath: "\(DST)/\(item)")
    }
    print("Done")

    try await withThrowingTaskGroup { group in
        print("Converting: ", terminator: "")
        group.addTask {
            print("title", terminator: " ")
            try run("\(CONV) \"\(ORIG)/OperationJeffTitle.png\" -pal-min -bitmap-y -bank-8k \"\(DST)/title.nxi\"")
        }
        group.addTask {
            print("info", terminator: " ")
            try run("\(CONV) \"\(ORIG)/OperationJeffInfo.png\" -pal-min -bitmap-y -bank-8k \"\(DST)/info.nxi\"")
        }
        group.addTask {
            print("gameover", terminator: " ")
            try run("\(CONV) \"\(ORIG)/OperationJeffGameOver.png\" -pal-min -bitmap-y -bank-8k \"\(DST)/gameOver.nxi\"")
        }
        try await group.waitForAll()
        print("Done")

        print("Compression: ", terminator: "")
        for screen in ["title", "info", "gameOver"] {
            group.addTask {
                for number in NUMBERS {
                    try run("\(COMPRESS) -f \"\(DST)/\(screen)_\(number).nxi\" \"\(DST)/\(screen)_\(number).nxi.zx0\"")
                }
                print("\(screen) ", terminator: "")
            }
        }
        try await group.waitForAll()
        print("Done")
    }

    print("Compression (Palettes): ", terminator: "")
    for palette in ["title", "info", "gameOver", "default"] {
        try run("\(COMPRESS) -f \"\(DST)/\(palette).nxp\" \"\(DST)/\(palette).nxp.zx0\"")
        print(palette, terminator: " ")
    }
    print("Done")

    let heightmaps = try fm.contentsOfDirectory(atPath: ORIG).filter {
        $0.hasPrefix("OperationJeffHeightmap") && $0.hasSuffix(".png")
    }

    print("Heightmaps: ", terminator: "")

    for file in heightmaps {
        print(file, terminator: " ")
        let outputData = convertHeightMap(at: "\(ORIG)/\(file)")
        let outputFileName = file.replacing(".png", with: ".hm")
        try outputData.write(to: URL(filePath: "\(DST)/\(outputFileName)"))
    }
    print("Done")

    print("Levels: ", terminator: "")

    try await withThrowingTaskGroup { group in
        for letter in LETTERS {
            group.addTask {
                try run("\(CONV) \"\(ORIG)/OperationJeffLevel\(letter).png\" -pal-min -bitmap-y -bank-8k \"\(DST)/level\(letter).nxi\"") 
                try run("\(COMPRESS) -f \"\(DST)/level\(letter).nxp\" \"\(DST)/level\(letter).nxp.zx0\"")

                try run("\(CONV) \"\(ORIG)/OperationJeffLevelComplete\(letter).png\" -pal-min -bitmap-y -bank-8k \"\(DST)/levelComplete\(letter).nxi\"") 
                try run("\(COMPRESS) -f \"\(DST)/levelComplete\(letter).nxp\" \"\(DST)/levelComplete\(letter).nxp.zx0\"")
                try run("\(COMPRESS) -f \"\(DST)/OperationJeffHeightmap\(letter).hm\" \"\(DST)/heightmap\(letter).hm.zx0\"")

                for number in NUMBERS {
                    try run("\(COMPRESS) -f \"\(DST)/level\(letter)_\(number).nxi\" \"\(DST)/level\(letter)_\(number).nxi.zx0\"")
                    try run("\(COMPRESS) -f \"\(DST)/levelComplete\(letter)_\(number).nxi\" \"\(DST)/levelComplete\(letter)_\(number).nxi.zx0\"")
                }

                print("\(letter) ", terminator: "")
            }
        }
        try await group.waitForAll()
        print("Done")
    }

    let filesDst = try fm.contentsOfDirectory(atPath: DST).filter {
        $0.hasSuffix(".nxp") || $0.hasSuffix(".nxi") || $0.hasSuffix(".hm")
    }
    for file in filesDst {
        try fm.removeItem(atPath: "\(DST)/\(file)")
    }

    let assetFiles = try fm.contentsOfDirectory(atPath: DST).filter {
        $0.hasSuffix(".nxp.zx0") || $0.hasSuffix(".pcm") || $0.hasSuffix(".nxi.zx0") || $0.hasSuffix(".spr") || $0.hasSuffix(".hm.zx0")
    }.map {
        DST + "/" + $0
    }
    makeAssets(from: assetFiles)

    print("Loading screen")
    try run("\(CONV) \"\(ORIG)/OperationJeffLoading.png\" -pal-min -pal-embed -bitmap \"\(DST)/loadingScreen.nxi\"") 
    print("All done")

} catch {
    print("Error: \(error)")
}
