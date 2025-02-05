import Foundation

// swift make-resources-asm.swift resources/*.nxp resources/*.spr resources/*.pcm resources/*.nxi

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
    var groups: [[FileInfo]] = []
    var currentGroup: [FileInfo] = []
    var currentSize: Int = 0
    let maxSize = 8 * 1024 // 8 KB
    var page = 29
    var allFiles = [FileInfo]()

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
    
    // Write the groups to an output file
    var outputContent = ""
    for group in groups {
        outputContent += """
        ;-------------------------------------------------
        
        SECTION PAGE_\(group.first!.page)\n
        """
        if group.first!.name.contains("nxp") {
            outputContent += "ORG 0x6000\n\n"
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
        extern ResourceInfo R_\(name);\n
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
        ResourceInfo R_\(name) = { &\(name), \(file.size), \(file.page) };\n
        """
    }

    do {
        try outputContent.write(to: URL(fileURLWithPath: "src/assets.c"), atomically: true, encoding: .utf8)
    } catch {
        print("Error writing to output file: \(error)")
    }
    
}

main()