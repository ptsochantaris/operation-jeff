// Run with `swift -O makeAssets.swift`

import CoreGraphics
import Foundation
import ImageIO
import Compression
import Foundation
import Foundation

let GAME_ROOT = ""
let ORIG = "resources_original"
let DST = "resources"
let LETTERS = "ABCDEFGHIJKLMNOPQ"
let NUMBERS = "0123456789"
let fm = FileManager.default

// Disable stdout buffering so partial prints (terminator: "") appear immediately
setvbuf(stdout, nil, _IONBF, 0)

do {
    if !GAME_ROOT.isEmpty {
        print("Working in \(GAME_ROOT)")
        guard fm.changeCurrentDirectoryPath(GAME_ROOT) else {
            fatalError("Could not change directory to GAME_ROOT: \(GAME_ROOT)")
        }
    }

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

    // Convert all heightmaps (CoreGraphics, sequential — they are small and fast).
    let heightmaps = try fm.contentsOfDirectory(atPath: ORIG).filter {
        $0.hasPrefix("OperationJeffHeightmap") && $0.hasSuffix(".png")
    }
    print("Heightmaps: ", terminator: "")
    var heightmapFiles = [String]()
    for file in heightmaps {
        print(file, terminator: " ")
        let outputData = convertHeightMap(at: "\(ORIG)/\(file)")
        let outputFileName = file.replacing(".png", with: ".hm")
        try outputData.write(to: URL(filePath: "\(DST)/\(outputFileName)"))
        heightmapFiles.append(outputFileName)
    }
    print("Done")

    // Phase A: convert every image to its raster banks (.nxi) + palette (.nxp).
    // Each conversion is independent, so run them all concurrently.
    print("Converting images... ", terminator: "")
    try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask { try convertBanked(from: "\(ORIG)/OperationJeffTitle.png", baseName: "title") }
        group.addTask { try convertBanked(from: "\(ORIG)/OperationJeffInfo.png", baseName: "info") }
        group.addTask { try convertBanked(from: "\(ORIG)/OperationJeffGameOver.png", baseName: "gameOver") }
        for letter in LETTERS {
            group.addTask { try convertBanked(from: "\(ORIG)/OperationJeffLevel\(letter).png", baseName: "level\(letter)") }
            group.addTask { try convertBanked(from: "\(ORIG)/OperationJeffLevelComplete\(letter).png", baseName: "levelComplete\(letter)") }
        }
        try await group.waitForAll()
    }
    print("Done")

    // Phase B: ZX0-compress every output file. Each file is an independent task
    // so the work spreads across all available cores.
    print("Compressing... ", terminator: "")
    try await withThrowingTaskGroup(of: Void.self) { group in
        // Raster banks (10 per image).
        let rasterBases = ["title", "info", "gameOver"] + LETTERS.flatMap { ["level\($0)", "levelComplete\($0)"] }
        for base in rasterBases {
            for number in NUMBERS {
                group.addTask { try compressFile("\(DST)/\(base)_\(number).nxi", to: "\(DST)/\(base)_\(number).nxi.zx0") }
            }
        }
        // Palettes (title/info/gameOver generated; default copied from source).
        let paletteBases = ["title", "info", "gameOver", "default"] + LETTERS.flatMap { ["level\($0)", "levelComplete\($0)"] }
        for base in paletteBases {
            group.addTask { try compressFile("\(DST)/\(base).nxp", to: "\(DST)/\(base).nxp.zx0") }
        }
        // Heightmaps (OperationJeffHeightmapX.hm -> heightmapX.hm.zx0).
        for hm in heightmapFiles {
            let suffix = hm.replacingOccurrences(of: "OperationJeffHeightmap", with: "").replacingOccurrences(of: ".hm", with: "")
            group.addTask { try compressFile("\(DST)/\(hm)", to: "\(DST)/heightmap\(suffix).hm.zx0") }
        }
        try await group.waitForAll()
    }
    print("Done")

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
    try convertEmbedded(from: "\(ORIG)/OperationJeffLoading.png", to: "\(DST)/loadingScreen.nxi")
    print("All done")

} catch {
    print("Error: \(error)")
}

// ----------------------------------------------------------------------- Top level calls

/// Converts a paletted PNG to banked Next raster files (`<base>_<n>.nxi`) plus a
/// `<base>.nxp` palette, matching `gfx2next <in> -pal-min -bitmap-y -bank-8k <out>`.
private func convertBanked(from pngPath: String, baseName: String) throws {
    let png = try decodeIndexedPNG(at: pngPath)
    let image = Gfx2Next.convert(png: png, layout: .bitmapY)
    for (index, bank) in Gfx2Next.banks(image.raster).enumerated() {
        try bank.write(to: URL(fileURLWithPath: "\(DST)/\(baseName)_\(index).nxi"))
    }
    try image.paletteBytes.write(to: URL(fileURLWithPath: "\(DST)/\(baseName).nxp"))
}

/// Converts a paletted PNG to a single raster file with the palette embedded at
/// the front, matching `gfx2next <in> -pal-min -pal-embed -bitmap <out>`.
private func convertEmbedded(from pngPath: String, to outPath: String) throws {
    let png = try decodeIndexedPNG(at: pngPath)
    let image = Gfx2Next.convert(png: png, layout: .row)
    var data = Data()
    data.append(image.paletteBytes)
    data.append(image.raster)
    try data.write(to: URL(fileURLWithPath: outPath))
}

/// ZX0-compresses a file, matching `zx0 -f <in> <out>`.
private func compressFile(_ inPath: String, to outPath: String) throws {
    let input = try Data(contentsOf: URL(fileURLWithPath: inPath))
    try zx0Compress(input).write(to: URL(fileURLWithPath: outPath))
    if let fileName = inPath.components(separatedBy: "/").last {
        print(fileName, terminator: " ")
    }
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

// ----------------------------------------------------------------------- ZX0
//
//  Swift port of the standalone ZX0 optimal data compressor (v2.2).
//  Ported only to the extent exercised by this tool: the default
//  `zx0 -f <input> <output>` behaviour (skip = 0, offset limit = 32640,
//  forward mode, interlaced/inverted Elias gamma). Produces byte-identical
//  output to the reference binary.
//
//  The optimal parser is the hot path (O(n * offset) per input), so its
//  working storage uses raw pointers to avoid Swift's array bounds and
//  copy-on-write overhead. The algorithm is a 1:1 translation of the C source.
//
//  Derived from ZX0 by Einar Saukas:
//  (c) Copyright 2021 by Einar Saukas. All rights reserved. (BSD 3-Clause)
//

/// Compresses `input` using ZX0 with the same parameters as `zx0 -f`.
/// A fresh instance is used per call so this is safe to run concurrently.
private func zx0Compress(_ input: [UInt8]) -> [UInt8] {
    ZX0(capacity: input.count * 4 + 1024).run(input)
}

private func zx0Compress(_ input: Data) -> Data {
    Data(zx0Compress([UInt8](input)))
}

private struct Block {
    var chain: Int = -1
    var ghostChain: Int = -1
    var bits: Int = 0
    var index: Int = 0
    var offset: Int = 0
    var references: Int = 0
}

private final class ZX0 {
    private static let initialOffset = 1
    private static let maxOffsetZX0 = 32640

    // MARK: Block pool (memory.c)
    //
    // Blocks live in a contiguous buffer, referenced by index (-1 == NULL).
    // The ghost-chain free list reclaims unreferenced blocks exactly as the C
    // original does, keeping the pool bounded; the buffer only grows when the
    // free list is empty and all slots are in use. Reclamation is purely a
    // memory optimisation and does not affect output.

    private var pool: UnsafeMutablePointer<Block>
    private var poolCapacity: Int
    private var poolUsed = 0
    private var ghostRoot = -1

    init(capacity: Int) {
        poolCapacity = max(capacity, 1024)
        pool = UnsafeMutablePointer<Block>.allocate(capacity: poolCapacity)
        pool.initialize(repeating: Block(), count: poolCapacity)
    }

    deinit {
        pool.deallocate()
    }

    @inline(__always)
    private func growPool() {
        let newCapacity = poolCapacity * 2
        let newPool = UnsafeMutablePointer<Block>.allocate(capacity: newCapacity)
        newPool.initialize(repeating: Block(), count: newCapacity)
        newPool.update(from: pool, count: poolUsed)
        pool.deallocate()
        pool = newPool
        poolCapacity = newCapacity
    }

    @inline(__always)
    private func allocate(_ bits: Int, _ index: Int, _ offset: Int, _ chain: Int) -> Int {
        let ptr: Int
        if ghostRoot != -1 {
            ptr = ghostRoot
            ghostRoot = pool[ptr].ghostChain
            let oldChain = pool[ptr].chain
            if oldChain != -1 {
                pool[oldChain].references -= 1
                if pool[oldChain].references == 0 {
                    pool[oldChain].ghostChain = ghostRoot
                    ghostRoot = oldChain
                }
            }
        } else {
            if poolUsed == poolCapacity { growPool() }
            ptr = poolUsed
            poolUsed += 1
        }
        pool[ptr].bits = bits
        pool[ptr].index = index
        pool[ptr].offset = offset
        if chain != -1 { pool[chain].references += 1 }
        pool[ptr].chain = chain
        pool[ptr].references = 0
        return ptr
    }

    @inline(__always)
    private func assign(_ slot: UnsafeMutablePointer<Int>, _ chain: Int) {
        pool[chain].references += 1
        let old = slot.pointee
        if old != -1 {
            pool[old].references -= 1
            if pool[old].references == 0 {
                pool[old].ghostChain = ghostRoot
                ghostRoot = old
            }
        }
        slot.pointee = chain
    }

    // MARK: Cost helpers (optimize.c)

    @inline(__always)
    private func offsetCeiling(_ index: Int, _ offsetLimit: Int) -> Int {
        if index > offsetLimit { return offsetLimit }
        if index < Self.initialOffset { return Self.initialOffset }
        return index
    }

    @inline(__always)
    private func eliasGammaBits(_ value: Int) -> Int {
        var bits = 1
        var v = value
        while true {
            v >>= 1
            if v == 0 { break }
            bits += 2
        }
        return bits
    }

    @inline(__always)
    private func makeIntBuffer(_ count: Int, _ value: Int) -> UnsafeMutablePointer<Int> {
        let p = UnsafeMutablePointer<Int>.allocate(capacity: count)
        p.initialize(repeating: value, count: count)
        return p
    }

    // MARK: Optimal parse (optimize.c)

    private func optimize(_ inputData: UnsafePointer<UInt8>, _ inputSize: Int, _ skip: Int, _ offsetLimit: Int) -> Int {
        var maxOffset = offsetCeiling(inputSize - 1, offsetLimit)

        let lastLiteral = makeIntBuffer(maxOffset + 1, -1)
        let lastMatch = makeIntBuffer(maxOffset + 1, -1)
        let optimal = makeIntBuffer(inputSize, -1)
        let matchLength = makeIntBuffer(maxOffset + 1, 0)
        let bestLength = makeIntBuffer(inputSize, 0)
        defer {
            lastLiteral.deallocate()
            lastMatch.deallocate()
            optimal.deallocate()
            matchLength.deallocate()
            bestLength.deallocate()
        }

        if inputSize > 2 {
            bestLength[2] = 2
        }

        // Start with fake block.
        assign(lastMatch + Self.initialOffset, allocate(-1, skip - 1, Self.initialOffset, -1))

        var index = skip
        while index < inputSize {
            var bestLengthSize = 2
            maxOffset = offsetCeiling(index, offsetLimit)
            var offset = 1
            while offset <= maxOffset {
                if index != skip && index >= offset && inputData[index] == inputData[index - offset] {
                    // Copy from last offset.
                    if lastLiteral[offset] != -1 {
                        let length = index - pool[lastLiteral[offset]].index
                        let bits = pool[lastLiteral[offset]].bits + 1 + eliasGammaBits(length)
                        assign(lastMatch + offset, allocate(bits, index, offset, lastLiteral[offset]))
                        if optimal[index] == -1 || pool[optimal[index]].bits > bits {
                            assign(optimal + index, lastMatch[offset])
                        }
                    }
                    // Copy from new offset.
                    matchLength[offset] += 1
                    if matchLength[offset] > 1 {
                        if bestLengthSize < matchLength[offset] {
                            var bits = pool[optimal[index - bestLength[bestLengthSize]]].bits + eliasGammaBits(bestLength[bestLengthSize] - 1)
                            repeat {
                                bestLengthSize += 1
                                let bits2 = pool[optimal[index - bestLengthSize]].bits + eliasGammaBits(bestLengthSize - 1)
                                if bits2 <= bits {
                                    bestLength[bestLengthSize] = bestLengthSize
                                    bits = bits2
                                } else {
                                    bestLength[bestLengthSize] = bestLength[bestLengthSize - 1]
                                }
                            } while bestLengthSize < matchLength[offset]
                        }
                        let length = bestLength[matchLength[offset]]
                        let bits = pool[optimal[index - length]].bits + 8 + eliasGammaBits((offset - 1) / 128 + 1) + eliasGammaBits(length - 1)
                        if lastMatch[offset] == -1 || pool[lastMatch[offset]].index != index || pool[lastMatch[offset]].bits > bits {
                            assign(lastMatch + offset, allocate(bits, index, offset, optimal[index - length]))
                            if optimal[index] == -1 || pool[optimal[index]].bits > bits {
                                assign(optimal + index, lastMatch[offset])
                            }
                        }
                    }
                } else {
                    // Copy literals.
                    matchLength[offset] = 0
                    if lastMatch[offset] != -1 {
                        let length = index - pool[lastMatch[offset]].index
                        let bits = pool[lastMatch[offset]].bits + 1 + eliasGammaBits(length) + length * 8
                        assign(lastLiteral + offset, allocate(bits, index, 0, lastMatch[offset]))
                        if optimal[index] == -1 || pool[optimal[index]].bits > bits {
                            assign(optimal + index, lastLiteral[offset])
                        }
                    }
                }
                offset += 1
            }
            index += 1
        }

        return optimal[inputSize - 1]
    }

    // MARK: Output bitstream (compress.c)

    private var output = [UInt8]()
    private var outputIndex = 0
    private var bitIndex = 0
    private var bitMask = 0
    private var diff = 0
    private var backtrack = false

    @inline(__always)
    private func readBytes(_ n: Int, _ delta: inout Int) {
        diff += n
        if delta < diff { delta = diff }
    }

    @inline(__always)
    private func writeByte(_ value: Int) {
        output[outputIndex] = UInt8(truncatingIfNeeded: value)
        outputIndex += 1
        diff -= 1
    }

    @inline(__always)
    private func writeBit(_ value: Bool) {
        if backtrack {
            if value { output[outputIndex - 1] |= 1 }
            backtrack = false
        } else {
            if bitMask == 0 {
                bitMask = 128
                bitIndex = outputIndex
                writeByte(0)
            }
            if value { output[bitIndex] |= UInt8(bitMask) }
            bitMask >>= 1
        }
    }

    private func writeInterlacedEliasGamma(_ value: Int, _ backwardsMode: Bool, _ invertMode: Bool) {
        var i = 2
        while i <= value { i <<= 1 }
        i >>= 1
        while true {
            i >>= 1
            if i == 0 { break }
            writeBit(backwardsMode)
            let dataBit = (value & i) != 0
            writeBit(invertMode ? !dataBit : dataBit)
        }
        writeBit(!backwardsMode)
    }

    private func emit(_ optimalTail: Int, _ inputData: UnsafePointer<UInt8>, _ inputSize: Int, _ skip: Int, _ backwardsMode: Bool, _ invertMode: Bool) -> [UInt8] {
        var lastOffset = Self.initialOffset

        let outputSize = (pool[optimalTail].bits + 25) / 8
        output = [UInt8](repeating: 0, count: outputSize)

        // Un-reverse optimal sequence.
        var prev = -1
        var cur = optimalTail
        while cur != -1 {
            let next = pool[cur].chain
            pool[cur].chain = prev
            prev = cur
            cur = next
        }

        // Initialise data.
        var delta = 0
        diff = outputSize - inputSize + skip
        var inputIndex = skip
        outputIndex = 0
        bitMask = 0
        backtrack = true

        // Generate output.
        var p = prev
        var o = pool[prev].chain
        while o != -1 {
            let length = pool[o].index - pool[p].index
            let offset = pool[o].offset

            if offset == 0 {
                writeBit(false)
                writeInterlacedEliasGamma(length, backwardsMode, false)
                for _ in 0 ..< length {
                    writeByte(Int(inputData[inputIndex]))
                    inputIndex += 1
                    readBytes(1, &delta)
                }
            } else if offset == lastOffset {
                writeBit(false)
                writeInterlacedEliasGamma(length, backwardsMode, false)
                inputIndex += length
                readBytes(length, &delta)
            } else {
                writeBit(true)
                writeInterlacedEliasGamma((offset - 1) / 128 + 1, backwardsMode, invertMode)
                if backwardsMode {
                    writeByte(((offset - 1) % 128) << 1)
                } else {
                    writeByte((127 - (offset - 1) % 128) << 1)
                }
                backtrack = true
                writeInterlacedEliasGamma(length - 1, backwardsMode, false)
                inputIndex += length
                readBytes(length, &delta)

                lastOffset = offset
            }

            p = o
            o = pool[o].chain
        }

        // End marker.
        writeBit(true)
        writeInterlacedEliasGamma(256, backwardsMode, invertMode)

        return output
    }

    // MARK: Entry point (matches `zx0 -f`)

    func run(_ input: [UInt8]) -> [UInt8] {
        if input.isEmpty { return [] }
        return input.withUnsafeBufferPointer { buffer -> [UInt8] in
            let base = buffer.baseAddress!
            let inputSize = buffer.count
            let tail = optimize(base, inputSize, 0, Self.maxOffsetZX0)
            return emit(tail, base, inputSize, 0, false, true)
        }
    }
}

// ----------------------------------------------------------------------- Gfx2Next
//
//  Swift port of the gfx2next conversion paths exercised by this tool:
//      gfx2next <in.png> -pal-min -bitmap-y -bank-8k <out.nxi>   (screens/levels)
//      gfx2next <in.png> -pal-min -pal-embed -bitmap <out.nxi>   (loading screen)
//
//  Both use the defaults colour_mode = DISTANCE and 8-bit (non-4bit) output.
//  Produces byte-identical .nxi/.nxp data to the reference binary.
//
//  Derived from Gfx2Next by RustyPixels (MIT License, 2020).
//

private enum RasterLayout {
    case bitmapY // -bitmap-y: column-major (320x256 layer 2)
    case row     // -bitmap: row-major
}

private struct NextImage {
    /// 256 entries * 2 bytes, little-endian (512 bytes).
    let paletteBytes: Data
    /// Palette indices arranged per the requested layout (width * height bytes).
    let raster: Data
}

private enum Gfx2Next {
    static let bankSize = 8192

    // MARK: Colour conversion helpers (gfx2next.c)

    private static func c8_to_c3(_ c8: Int) -> Int {
        // COLORMODE_DISTANCE behaves as ROUND.
        Int((Double(c8) * 7.0 / 255.0).rounded())
    }

    private static func c3_to_c8(_ c3: Int) -> Int {
        Int((Double(c3) * 255.0 / 7.0).rounded())
    }

    private static func rgb888(_ r: Int, _ g: Int, _ b: Int) -> Int {
        (r << 16) | (g << 8) | b
    }

    private static func rgb888_to_rgb333(_ packed: Int) -> Int {
        let r8 = (packed >> 16) & 0xff
        let g8 = (packed >> 8) & 0xff
        let b8 = packed & 0xff
        return (c8_to_c3(r8) << 6) | (c8_to_c3(g8) << 3) | c8_to_c3(b8)
    }

    private static func rgb333_to_rgb888(_ rgb333: Int) -> Int {
        let r3 = (rgb333 >> 6) & 7
        let g3 = (rgb333 >> 3) & 7
        let b3 = rgb333 & 7
        return rgb888(c3_to_c8(r3), c3_to_c8(g3), c3_to_c8(b3))
    }

    /// Nearest of the 512 RGB333 colours by Euclidean distance (use_333 path).
    /// Squared distance preserves the reference's ordering and tie-breaking.
    private static func nearestRGB333Color(_ packed: Int) -> Int {
        let r = (packed >> 16) & 0xff
        let g = (packed >> 8) & 0xff
        let b = packed & 0xff
        var match = 0
        var minDist = Double.greatestFiniteMagnitude
        for i in 0 ..< 512 {
            let pal = rgb333_to_rgb888(i)
            let rp = (pal >> 16) & 0xff
            let gp = (pal >> 8) & 0xff
            let bp = pal & 0xff
            let dr = Double(rp - r), dg = Double(gp - g), db = Double(bp - b)
            let dist = dr * dr + dg * dg + db * db
            if dist < minDist {
                match = pal
                minDist = dist
                if dist == 0 { return pal }
            }
        }
        return match
    }

    // MARK: Conversion

    /// Reproduces gfx2next's process_palette (DISTANCE + pal-min) and
    /// create_next_palette, plus the pixel-index remap and raster layout.
    static func convert(png: DecodedPNG, layout: RasterLayout) -> NextImage {
        // Build the full 256-entry palette (unused entries are black), then
        // convert every colour to its nearest RGB333 representation.
        var converted = [Int](repeating: 0, count: 256)
        for i in 0 ..< 256 {
            let src: Int
            if i < png.palette.count {
                let c = png.palette[i]
                src = rgb888(Int(c.r), Int(c.g), Int(c.b))
            } else {
                src = 0
            }
            converted[i] = nearestRGB333Color(src)
        }

        // Minimise: sort ascending, remove duplicates, pad the tail with 0.
        let sorted = converted.sorted()
        var minimized = [Int](repeating: 0, count: 256)
        var unique = 0
        minimized[0] = sorted[0]
        for i in 1 ..< 256 where sorted[i] != minimized[unique] {
            unique += 1
            minimized[unique] = sorted[i]
        }
        // Entries beyond `unique` remain 0 (matches padding to black).

        // Map each converted colour to its first index in the minimised palette.
        var firstIndex = [Int: Int]()
        for j in 0 ... unique where firstIndex[minimized[j]] == nil {
            firstIndex[minimized[j]] = j
        }
        var indexMap = [Int](repeating: 0, count: 256)
        for i in 0 ..< 256 {
            indexMap[i] = firstIndex[converted[i]] ?? 0
        }

        // Remap pixels to minimised-palette indices.
        var remapped = [UInt8](repeating: 0, count: png.indices.count)
        for i in 0 ..< png.indices.count {
            remapped[i] = UInt8(truncatingIfNeeded: indexMap[Int(png.indices[i])])
        }

        // Build the Next palette (512 bytes, little-endian uint16 per entry).
        var paletteBytes = Data(capacity: 512)
        for i in 0 ..< 256 {
            let rgb333 = rgb888_to_rgb333(minimized[i])
            let rgb332 = (rgb333 >> 1) & 0xff
            let b1 = rgb333 & 1
            let word = (b1 << 8) | rgb332
            paletteBytes.append(UInt8(word & 0xff))
            paletteBytes.append(UInt8((word >> 8) & 0xff))
        }

        // Arrange the raster.
        let width = png.width
        let height = png.height
        var raster = [UInt8](repeating: 0, count: width * height)
        switch layout {
        case .row:
            raster = remapped
        case .bitmapY:
            for y in 0 ..< height {
                for x in 0 ..< width {
                    raster[y + x * height] = remapped[y * width + x]
                }
            }
        }

        return NextImage(paletteBytes: paletteBytes, raster: Data(raster))
    }

    /// Splits raster data into 8 KB banks, matching `-bank-8k`.
    static func banks(_ raster: Data) -> [Data] {
        var result = [Data]()
        var offset = 0
        while offset < raster.count {
            let end = min(offset + bankSize, raster.count)
            result.append(raster.subdata(in: offset ..< end))
            offset = end
        }
        return result
    }
}

// ----------------------------------------------------------------------- PNGDecoder
//
//  Minimal PNG decoder for 8-bit paletted (colour type 3) images, which is
//  the only format gfx2next accepts. Parses IHDR/PLTE/IDAT, inflates the
//  image data with the system Compression framework and reverses the PNG
//  scanline filters. Returns the raw palette indices and the palette table,
//  exactly as gfx2next obtains them from LodePNG.
//

private struct DecodedPNG {
    let width: Int
    let height: Int
    /// One palette index per pixel, row-major (count == width * height).
    let indices: [UInt8]
    /// Palette entries from the PLTE chunk, in file order (RGB).
    let palette: [(r: UInt8, g: UInt8, b: UInt8)]
}

private enum PNGDecodeError: Error {
    case notAPNG
    case unsupportedFormat(String)
    case truncated
    case inflateFailed
}

private func decodeIndexedPNG(at path: String) throws -> DecodedPNG {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    return try decodeIndexedPNG(data)
}

private func decodeIndexedPNG(_ data: Data) throws -> DecodedPNG {
    let bytes = [UInt8](data)
    let signature: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
    guard bytes.count > 8, Array(bytes[0 ..< 8]) == signature else {
        throw PNGDecodeError.notAPNG
    }

    func be32(_ offset: Int) -> Int {
        (Int(bytes[offset]) << 24) | (Int(bytes[offset + 1]) << 16) | (Int(bytes[offset + 2]) << 8) | Int(bytes[offset + 3])
    }

    var width = 0
    var height = 0
    var palette = [(r: UInt8, g: UInt8, b: UInt8)]()
    var idat = [UInt8]()

    var p = 8
    while p + 8 <= bytes.count {
        let length = be32(p)
        let typeStart = p + 4
        guard typeStart + 4 <= bytes.count else { throw PNGDecodeError.truncated }
        let type = String(bytes: bytes[typeStart ..< typeStart + 4], encoding: .ascii) ?? ""
        let dataStart = typeStart + 4
        guard dataStart + length + 4 <= bytes.count else { throw PNGDecodeError.truncated }

        switch type {
        case "IHDR":
            width = be32(dataStart)
            height = be32(dataStart + 4)
            let bitDepth = bytes[dataStart + 8]
            let colorType = bytes[dataStart + 9]
            let interlace = bytes[dataStart + 12]
            guard bitDepth == 8, colorType == 3 else {
                throw PNGDecodeError.unsupportedFormat("Must be an 8-bit paletted image (bitDepth=\(bitDepth), colorType=\(colorType))")
            }
            guard interlace == 0 else {
                throw PNGDecodeError.unsupportedFormat("Interlaced PNGs are not supported")
            }
        case "PLTE":
            var i = dataStart
            while i + 3 <= dataStart + length {
                palette.append((bytes[i], bytes[i + 1], bytes[i + 2]))
                i += 3
            }
        case "IDAT":
            idat.append(contentsOf: bytes[dataStart ..< dataStart + length])
        case "IEND":
            p = bytes.count
            continue
        default:
            break
        }

        p = dataStart + length + 4 // skip data + CRC
    }

    guard width > 0, height > 0 else { throw PNGDecodeError.truncated }

    // Inflate the zlib stream. The system Compression framework's ZLIB
    // algorithm is raw DEFLATE (RFC 1951), so drop the 2-byte zlib header
    // and the trailing 4-byte Adler-32 checksum.
    guard idat.count > 6 else { throw PNGDecodeError.inflateFailed }
    let deflate = Array(idat[2 ..< idat.count - 4])

    let stride = width + 1 // one filter-type byte per scanline + width pixels
    let rawSize = stride * height
    var raw = [UInt8](repeating: 0, count: rawSize)
    let produced = deflate.withUnsafeBufferPointer { src -> Int in
        raw.withUnsafeMutableBufferPointer { dst in
            compression_decode_buffer(dst.baseAddress!, rawSize, src.baseAddress!, src.count, nil, COMPRESSION_ZLIB)
        }
    }
    guard produced == rawSize else { throw PNGDecodeError.inflateFailed }

    // Reverse the per-scanline filters (bpp == 1 for 8-bit indexed).
    var indices = [UInt8](repeating: 0, count: width * height)
    let bpp = 1
    for y in 0 ..< height {
        let filterType = raw[y * stride]
        let rowIn = y * stride + 1
        let rowOut = y * width
        for x in 0 ..< width {
            let value = Int(raw[rowIn + x])
            let a = x >= bpp ? Int(indices[rowOut + x - bpp]) : 0          // left
            let b = y > 0 ? Int(indices[rowOut - width + x]) : 0           // up
            let c = (y > 0 && x >= bpp) ? Int(indices[rowOut - width + x - bpp]) : 0 // up-left
            let recon: Int
            switch filterType {
            case 0: recon = value
            case 1: recon = value + a
            case 2: recon = value + b
            case 3: recon = value + (a + b) / 2
            case 4: recon = value + paeth(a, b, c)
            default: throw PNGDecodeError.unsupportedFormat("Unknown filter type \(filterType)")
            }
            indices[rowOut + x] = UInt8(truncatingIfNeeded: recon)
        }
    }

    return DecodedPNG(width: width, height: height, indices: indices, palette: palette)
}

private func paeth(_ a: Int, _ b: Int, _ c: Int) -> Int {
    let p = a + b - c
    let pa = abs(p - a)
    let pb = abs(p - b)
    let pc = abs(p - c)
    if pa <= pb && pa <= pc { return a }
    if pb <= pc { return b }
    return c
}
