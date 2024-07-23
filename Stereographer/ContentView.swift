//
//  ContentView.swift
//

import AppKit
import SwiftUI

struct ContentView: View {
	@Binding var document: StereoImageDocument
	
	@State private var pan: Double = 0
	@State private var separation: Double = 0
	@State private var textFieldValue: String = ""
	
	let outputImageDPI: Double = 450.0
	
	func getCurrentDisplayDPI() -> CGFloat {
		guard let screen = NSScreen.main else { return 72.0 }
		
		let description = screen.deviceDescription
		guard let screenNumber = description[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return 72.0 }
		
		let displayID = screenNumber.uint32Value
		
		// Get the main display's mode
		guard let mode = CGDisplayCopyDisplayMode(displayID) else {
			return 72.0
		}
		
		// Get the physical size of the display in millimeters
		let physicalSize = CGDisplayScreenSize(displayID)
		
		// Convert mm to inches
		let widthInInches = physicalSize.width / 25.4
		
		// Get the pixel width of the display
		let pixelWidth = CGFloat(mode.pixelWidth)
		
		// Calculate DPI
		let dpi = pixelWidth / widthInInches
		
		// Odd scalar I needed for my display.
		return dpi / 2.0
	}
	
	func aspectDelta (image: NSImage) -> Int {
		return Int (round (image.size.width - image.size.height))
	}
	
	func adjustedImage (sourceImage: NSImage?, pan: Double) -> NSImage? {
		var finalImage: NSImage?
		let width = Int (3 * outputImageDPI)
		let height = Int (3 * outputImageDPI)
		let bitsPerComponent = 8
		let bytesPerRow = width * 4
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		
		guard let unwrappedSourceImage = sourceImage else {
			print("Param error")
			return finalImage
		}

		guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
				bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
			print("Unable to create context")
			return finalImage
		}
		
		// Fill the context with a white background
		context.setFillColor (NSColor.white.cgColor)
		context.fill (CGRect (x: 0, y: 0, width: width, height: height))
		
		// Scale
		context.saveGState()
		let scale = Double (height) / unwrappedSourceImage.size.height;
		context.scaleBy (x: scale, y: scale)
		
		// Draw the image into the context
		let halfDelta = round (Double (aspectDelta (image: unwrappedSourceImage)) / -2.0)
		if let cgImage = unwrappedSourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
			context.draw (cgImage, in: CGRect (x: halfDelta + pan, y: 0, width: unwrappedSourceImage.size.width, height: unwrappedSourceImage.size.height))
		}
		context.restoreGState()
		
		// Create an image from the context
		guard let cgImage = context.makeImage() else {
			print("Unable to create CGImage")
			return finalImage
		}
		
		finalImage = NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
		return finalImage
	}
	
	func drawText (in context: CGContext, text: String, centeredOn point: CGPoint, color: NSColor) {
		// Save the current graphics state
		context.saveGState()
		
		// Create an attributed string with the text and attributes
		let attributes: [NSAttributedString.Key: Any] = [
			.font: NSFont.boldSystemFont (ofSize: 10.0 * outputImageDPI / 72.0),
			.foregroundColor: color
		]
		let attributedString = NSAttributedString (string: text, attributes: attributes)
		let textSize = attributedString.size()
		
		// Create a CTLine from the attributed string
		let line = CTLineCreateWithAttributedString(attributedString)
		
		// Set the text position in the context
		context.textPosition.x = point.x - (textSize.width / 2.0)
		context.textPosition.y = point.y
		
		// Draw the line
		CTLineDraw(line, context)
		
		// Restore the graphics state
		context.restoreGState()
	}

	func compositeImage (leftImage: NSImage, rightImage: NSImage) -> NSImage? {
		var finalImage: NSImage?
		let width = Int (outputImageDPI * 7.0)
		let height = Int (outputImageDPI * 3.5)
		let bitsPerComponent = 8
		let bytesPerRow = width * 4
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		
		guard let context = CGContext(data: nil, width: Int (width), height: Int (height), bitsPerComponent: bitsPerComponent,
				bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
			print("Unable to create context")
			return finalImage
		}
		
		// Fill the context with a white background
		context.setFillColor (NSColor.white.cgColor)
		context.fill (CGRect (x: 0, y: 0, width: Int (width), height: Int (height)))
		
		// Left
		if let leftCGImage = leftImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
			context.draw (leftCGImage, in: CGRect (x: 0.5 * outputImageDPI, y: 0.375 * outputImageDPI, width: leftImage.size.width, height: leftImage.size.height))
		}
		
		// Right
		if let rightCGImage = rightImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
			context.draw (rightCGImage, in: CGRect (x: 3.5 * outputImageDPI, y: 0.375 * outputImageDPI, width: rightImage.size.width, height: rightImage.size.height))
		}
		
		// Draw mask overlay.
		if let maskImage = NSImage (named: NSImage.Name("CardMask")), let maskCGImage = maskImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
			context.draw (maskCGImage, in: CGRect (x: 0, y: 0, width: 7.0 * outputImageDPI, height: 3.5 * outputImageDPI))
		}
		let xOffset = 0.03
		let yOffset = -0.03
		let xSeparation = 0.02
		drawText (in: context, text: textFieldValue, centeredOn: CGPoint (x: outputImageDPI * (2.0 + xOffset), y: outputImageDPI * (0.17 + yOffset)),
				color: NSColor.black.withAlphaComponent (0.5))
		drawText (in: context, text: textFieldValue, centeredOn: CGPoint (x: outputImageDPI * (5.0 + xOffset), y: outputImageDPI * (0.17 + yOffset)),
				color: NSColor.black.withAlphaComponent(0.5))
		drawText (in: context, text: textFieldValue, centeredOn: CGPoint (x: outputImageDPI * (2.0 + xSeparation), y: outputImageDPI * 0.17), 
				color: NSColor.white)
		drawText (in: context, text: textFieldValue, centeredOn: CGPoint (x: outputImageDPI * (5.0 - xSeparation), y: outputImageDPI * 0.17), 
				color: NSColor.white)
		
		// Create an image from the context
		guard let cgImage = context.makeImage() else {
			print("Unable to create CGImage")
			return finalImage
		}
		
		finalImage = NSImage(cgImage: cgImage, size: NSSize(width: Int (width), height: Int (height)))
		return finalImage
	}
	
	func stereogram () -> NSImage? {
		guard let srcLeftImage = document.leftImage, let srcRightImage = document.rightImage else {
			return nil;
		}
		
		let aspectScale = Double (aspectDelta (image: srcLeftImage)) / 2.0
		let minPan = -aspectScale
		let maxPan = aspectScale
		let leftPan = min (max ((pan * aspectScale) - (separation * (aspectScale / 2.0)), minPan), maxPan)
		let rightPan = min (max ((pan * aspectScale) + (separation * (aspectScale / 2.0)), minPan), maxPan)
		
		if let leftImage = adjustedImage (sourceImage: srcLeftImage, pan: Double(leftPan)),
				let rightImage = adjustedImage (sourceImage: srcRightImage, pan: Double(rightPan)) {
			return compositeImage (leftImage: leftImage, rightImage: rightImage)
		} else {
			return nil
		}
	}
	
	func exportImage() {
		if let image = stereogram () {
			// Show the save panel
			let savePanel = NSSavePanel()
			savePanel.allowedFileTypes = ["jpg"]
			savePanel.begin { response in
				if response == .OK, let url = savePanel.url {
					// Convert the image to JPEG data with 450 DPI
					if let tiffData = image.tiffRepresentation,
					   let bitmap = NSBitmapImageRep(data: tiffData) {
						bitmap.size = NSSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh) // Ensure size is set to pixel dimensions
						bitmap.setProperty(.compressionFactor, withValue: 1.0) // Max quality JPEG
						
						let dpi: CGFloat = outputImageDPI
						let scale = dpi / 72.0
						bitmap.size = NSSize(width: CGFloat(bitmap.pixelsWide) / scale, height: CGFloat(bitmap.pixelsHigh) / scale)
						
						if let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 1.0]) {
							// Write the JPEG data to the file
							do {
								try jpegData.write(to: url)
							} catch {
								print("Error saving file: \(error)")
							}
						}
					}
				}
			}
		}
	}
	
	var body: some View {
		let dpi = getCurrentDisplayDPI()
		
		VStack {
			if let stereogramImage = stereogram () {
				Image(nsImage: stereogramImage)
					.resizable()
					.frame(width: 7.0 * dpi, height: 3.5 * dpi)
			} else {
				Image("CardMask")
					.resizable()
					.frame(width: 7.0 * dpi, height: 3.5 * dpi)
			}
			HStack {
				VStack {
					Text("Pan")
					Slider(value: $pan, in: -1...1)
						.overlay(
							GeometryReader { geometry in
								let tickPosition = geometry.size.width / 2
								VStack {
									Spacer()
									Rectangle()
										.fill(Color.gray)
										.frame(width: 2, height: 16)
										.position(x: tickPosition, y: 20)
								}
							}
						)
				}
				.padding()

				VStack {
					Text("Separation")
					Slider(value: $separation, in: -1...1)
						.overlay(
							GeometryReader { geometry in
								let tickPosition = geometry.size.width / 2
								VStack {
									Spacer()
									Rectangle()
										.fill(Color.gray)
										.frame(width: 2, height: 16)
										.position(x: tickPosition, y: 20)
								}
							}
						)
				}
				.padding()

				VStack {
					Text("Text Field:")
					TextField("Description", text: $textFieldValue)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.frame(minWidth: 300)
				}
				.padding()
			}
			
			HStack {
				Spacer()
				Button(action: {
					exportImage()
				}) {
					Text ("Export Image…")
				}
				.padding()
			}
		}
		.padding()
	}
}
