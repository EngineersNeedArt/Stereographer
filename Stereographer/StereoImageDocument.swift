//
//  StereoImageDocument.swift
//

import SwiftUI
import UniformTypeIdentifiers


struct StereoImageDocument: FileDocument {
	static var readableContentTypes: [UTType] { [.data] }
	
	var leftImage: NSImage?
	var rightImage: NSImage?
	
	init () {
		//
	}
	
	init (fileURL: URL) {
		let imageExtractor = ImageExtractor()
		let images = imageExtractor.extractImages(from: fileURL)
		if images.count >= 2 {
			self.leftImage = images[0]
			self.rightImage = images[1]
		}
	}
	
	init (configuration: ReadConfiguration) throws {
		guard let mpoData = configuration.file.regularFileContents else {
			throw CocoaError(.fileReadCorruptFile)
		}
		
		// Write the MPO data to a temporary file
		let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".mpo")
		try mpoData.write(to: tempURL)
		
		let imageExtractor = ImageExtractor()
		let images = imageExtractor.extractImages(from: tempURL)
		if images.count >= 2 {
			self.leftImage = images[0]
			self.rightImage = images[1]
		}
	}
	
	func fileWrapper (configuration: WriteConfiguration) throws -> FileWrapper {
		// Placeholder implementation required by the protocol
		return FileWrapper (regularFileWithContents: Data())
	}
}
