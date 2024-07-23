// ChatGPT:
/*
import Foundation
import AppKit
import ImageIO

class ImageExtractor {
	func extractImages(from mpoFilePath: URL) -> [NSImage] {
		guard let mpoData = try? Data(contentsOf: mpoFilePath) else {
			print("Failed to read MPO file data.")
			return []
		}

		var images = [NSImage]()
		let jpegRanges = findAllJPEGRanges(in: mpoData)
		
		for range in jpegRanges {
			let jpegData = mpoData.subdata(in: range)
			if let image = createImage(from: jpegData) {
				if isFullSizeImage(image) {
					images.append(image)
				}
			} else {
				print("Failed to create image from data in range \(range).")
			}
		}

		if images.isEmpty {
			print("No full-size images extracted.")
		}

		return images
	}
	
	/*
	private func findAllJPEGRanges(in data: Data) -> [Range<Int>] {
		var ranges = [Range<Int>]()
		var pos = 0
		while pos < data.count - 1 {
			if data[pos] == 0xFF && data[pos + 1] == 0xD8 {
				let start = pos
				pos += 2
				while pos < data.count - 1 {
					if data[pos] == 0xFF && data[pos + 1] == 0xD9 {
						let end = pos + 2
						ranges.append(start..<end)
						pos = end
						break
					}
					pos += 1
				}
			} else {
				pos += 1
			}
		}
		return ranges
	}
	*/
	
	private func findAllJPEGRanges(in data: Data) -> [Range<Int>] {
		var ranges = [Range<Int>]()
		var pos = 0
		while pos < data.count - 1 {
			if data[pos] == 0xFF && data[pos + 1] == 0xD8 {
				let start = pos
				pos += 2
				while pos < data.count - 1 {
					if data[pos] == 0xFF && data[pos + 1] == 0xD9 {
						let end = pos + 2
						ranges.append(start..<end)
						print("Found JPEG range from \(start) to \(end)")
						pos = end
						break
					}
					pos += 1
				}
			} else {
				pos += 1
			}
		}
		return ranges
	}
	/*
	private func createImage(from data: Data) -> NSImage? {
		guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
			  let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
			print("Failed to create CGImage from data.")
			return nil
		}
		let image = NSImage(cgImage: cgImage, size: NSZeroSize)
		print("Created image with size \(image.size.width)x\(image.size.height)")
		return image
	}
	*/
	
	private func createImage(from data: Data) -> NSImage? {
		guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
			  let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
			print("Failed to create CGImage from data of length \(data.count).")
			return nil
		}
		let image = NSImage(cgImage: cgImage, size: NSZeroSize)
		print("Created image with size \(image.size.width)x\(image.size.height)")
		return image
	}
	
	private func isFullSizeImage(_ image: NSImage) -> Bool {
		// Assuming a typical threshold for distinguishing full-size images from thumbnails
		let thresholdWidth: CGFloat = 1000.0
		let thresholdHeight: CGFloat = 1000.0
		return image.size.width > thresholdWidth && image.size.height > thresholdHeight
	}
}
*/

import Foundation
import AppKit

class ImageExtractor {
	func extractImages(from mpoURL: URL) -> [NSImage] {
		guard let data = try? Data(contentsOf: mpoURL) else {
			return []
		}
		
		let jpegMarker: [UInt8] = [0xFF, 0xD8]
		var images: [NSImage] = []
		var searchIndex = 0
		
		while searchIndex < data.count - 1 {
			if data[searchIndex] == jpegMarker[0] && data[searchIndex + 1] == jpegMarker[1] {
				let jpegData = data[searchIndex...]
				if let image = NSImage(data: jpegData) {
					if isFullSizeImage(image) {
						images.append(image)
					}
				}
				searchIndex += 1
			} else {
				searchIndex += 1
			}
		}
		
		return images
	}
	
	private func isFullSizeImage(_ image: NSImage) -> Bool {
		// Assuming a typical threshold for distinguishing full-size images from thumbnails
		let thresholdWidth: CGFloat = 1000.0
		let thresholdHeight: CGFloat = 1000.0
		return image.size.width > thresholdWidth && image.size.height > thresholdHeight
	}

}
