//
//  ImageExtractor.swift
//


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
