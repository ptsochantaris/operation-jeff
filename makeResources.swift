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
    
    struct FileInfo {
        let name: String
        let size: Int
        var page: Int
        
        var variableName: String {
            name.replacingOccurrences(of: ".", with: "_").components(separatedBy: "/").last!
        }
    }

    // Dictionary to store groups of files
    var currentGroup = [FileInfo]()
    var groups = [[FileInfo]]()
    var allFiles = [FileInfo]()
    let maxSize = 8 * 1024 // 8 KB
    var currentSize = 0
    var page = 29

    // Process each file
    for filePath in filePaths where !filePath.contains("loadingScreen.") {
        if let fileSize = getFileSize(filePath) {
            var info = FileInfo(name: filePath, size: fileSize, page: page)
            if currentSize + fileSize <= maxSize {
                // Add file to the current group
                currentGroup.append(info)
                currentSize += fileSize
            } else {
                // Start a new group
                page += Int((Double(currentSize) / Double(maxSize)).rounded(.up))
                info.page = page
                groups.append(currentGroup)
                currentGroup = [info]
                currentSize = fileSize
            }
        }
    }

    // Add the last group if it's not empty
    if !currentGroup.isEmpty {
        groups.append(currentGroup)
    }

    for _ in 0 ..< 10 {
        var defragmenting = true
        while defragmenting {
            defragmenting = false
            // defrag pages after the initial one (which is mapped to 0x6000)
            pass: for defragmentingGroupIndex in 1 ..< groups.count - 1 {
                var groupWithPotentialSpace = groups[defragmentingGroupIndex]
                let totalSize = groupWithPotentialSpace.reduce(0) { $0 + $1.size }
                let remaining = maxSize - totalSize
                if remaining > 8 {
                    for examiningGroupIndex in defragmentingGroupIndex + 1 ..< groups.count {
                        var potentialDonorGroup = groups[examiningGroupIndex]
                        for potentialTransplantIndex in 0 ..< potentialDonorGroup.count {
                            var potentialTransplant = potentialDonorGroup[potentialTransplantIndex]
                            if potentialTransplant.size < remaining {
                                //let previousPage = potentialTransplant.page
                                potentialTransplant.page = groupWithPotentialSpace.first!.page
                                //print("Moving asset \(potentialTransplant.name) from page \(previousPage) to \(potentialTransplant.page)")
                                groupWithPotentialSpace.append(potentialTransplant)
                                potentialDonorGroup.remove(at: potentialTransplantIndex)
                                groups[defragmentingGroupIndex] = groupWithPotentialSpace
                                if potentialDonorGroup.isEmpty {
                                    groups.remove(at: examiningGroupIndex)
                                } else {
                                    groups[examiningGroupIndex] = potentialDonorGroup
                                }
                                defragmenting = true
                                break pass
                            }
                        }
                    }
                }
            }
        }
    }

    var newPage = 28
    groups = groups.map { group in
        newPage += 1
        let remappedGroup = group.map { var entry = $0; entry.page = newPage; return entry }
        let size = remappedGroup.reduce(0) { $0 + $1.size }
        if size > maxSize {
            newPage += 1
        }
        return remappedGroup
    }
    
    // Write the groups to an output file
    var outputContent = ""
    var isFirst = true
    for group in groups {
        outputContent += """
        ;-------------------------------------------------
        
        SECTION PAGE_\(group.first!.page)\n
        """
        if isFirst {
            outputContent += "ORG 0x6000\n\n"
            isFirst = false
        } else {
            outputContent += "ORG 0x2000\n\n"
        }
        for file in group {
            allFiles.append(file)
            let name = file.variableName
            outputContent +=
            """
            PUBLIC _\(name) ; \(file.size) bytes
            _\(name): BINARY "\(file.name)"
            \n
            """
        }
    }

    do {
        try outputContent.write(to: URL(fileURLWithPath: "src/assetBinaries.asm"), atomically: true, encoding: .utf8)
    } catch {
        print("Error writing to output file: \(error)")
    }

    outputContent = """
    #ifndef __ASSETS_H__
    #define __ASSETS_H__

    #include "types.h"

    typedef struct {
        byte *resource;
        word length;
        byte page;        
    } ResourceInfo;\n\n
    """
    for file in allFiles {
        let name = file.variableName
        outputContent += """
        extern const ResourceInfo R_\(name);\n
        """
    }
    outputContent += "\n#endif\n"

    do {
        try outputContent.write(to: URL(fileURLWithPath: "src/assets.h"), atomically: true, encoding: .utf8)
    } catch {
        print("Error writing to output file: \(error)")
    }

    outputContent = """
    #include "assets.h"
    """
    for file in allFiles {
        let name = file.variableName
        outputContent += """
        \nextern word \(name);
        const ResourceInfo R_\(name) = { &\(name), \(file.size), \(file.page) };\n
        """
    }

    do {
        try outputContent.write(to: URL(fileURLWithPath: "src/assets.c"), atomically: true, encoding: .utf8)
    } catch {
        print("Error writing to output file: \(error)")
    }
    
}

main()