import Foundation

// swift makeResources.swift resources/*.nxp resources/*.spr resources/*.pcm resources/*.nxi

func main() {
    // Check if there are any file paths provided as command-line arguments
    guard CommandLine.arguments.count > 1 else {
        print("Usage: \(CommandLine.arguments[0]) <file1> <file2> ...")
        exit(1)
    }

    // Remove the first argument (the program name) and get the file paths
    let filePaths = Array(CommandLine.arguments.dropFirst())

    // Function to get the file size in bytes
    func getFileSize(_ path: String) -> Int? {
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
    
    struct FileGroup {
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

    struct FileInfo {
        let name: String
        let size: Int
        var pos: Int
        
        var variableName: String {
            name.replacingOccurrences(of: ".", with: "_").components(separatedBy: "/").last!
        }
    }

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

    var firstPage = 29

    mmu3Files = mmu3Files.sorted { $0.size > $1.size }
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

    mmu1Files = mmu1Files.sorted { $0.size > $1.size }
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
    } catch {
        print("Error writing to output file: \(error)")
    }    
}

main()