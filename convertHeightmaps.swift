import CoreGraphics
import Foundation
import ImageIO

func convert(imagePath: String) -> Data {
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

func main() {
    guard CommandLine.arguments.count > 1 else {
        print("Usage: \(CommandLine.arguments[0]) <file1> <file2> …")
        exit(1)
    }

    let filePaths = Array(CommandLine.arguments.dropFirst())
    for file in filePaths {
        print("   Heightmap \(file)… ", terminator: "")
        let outputFileName = file.replacing(".png", with: ".hm")
        let outputData = convert(imagePath: file)
        try! outputData.write(to: URL(filePath: outputFileName))
        print("-> \(outputFileName)")
    }
}

main()
