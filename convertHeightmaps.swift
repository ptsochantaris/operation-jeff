import Cocoa
import Foundation

func main() {
    guard CommandLine.arguments.count > 1 else {
        print("Usage: \(CommandLine.arguments[0]) <file1> <file2> …")
        exit(1)
    }

    let filePaths = Array(CommandLine.arguments.dropFirst())
    for file in filePaths {
        print("Converting \(file)… ", terminator: "")
        if let image = NSImage(contentsOfFile: file) {
            let raw = NSBitmapImageRep(data: image.tiffRepresentation!)!
            var outputData = Data()
            for y in 0 ..< Int(image.size.height) {
                for x in 0 ..< Int(image.size.width) {
                    let color: NSColor = raw.colorAt(x: x, y: y)!
                    let b = UInt8(color.brightnessComponent * 255)
                    outputData.append(b / 10)
                }
            }
            let outputFileName = file.replacing(".png", with: ".hm")
            try! outputData.write(to: URL(filePath: outputFileName))
            print("-> \(outputFileName)")
        } else {
            print("File not found")
        }
    }
}

main()
