//
//  ContentView.swift
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
	@Binding var document: StereoImageDocument
	
	@State private var pan: Double = 0
	@State private var separation: Double = 0
	@State private var straighten: Double = 0
	@State private var textFieldValue: String = ""
	
	let outputImageDPI: Double = 450.0
	
	private func getCurrentDisplayDPI() -> CGFloat {
		guard let screen = NSScreen.main else {
			return 72.0
		}
		
		let description = screen.deviceDescription
		guard let screenNumber = description[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
			return 72.0
		}
		
		let displayID = screenNumber.uint32Value
		
		// Get the main display's mode
		guard let mode = CGDisplayCopyDisplayMode (displayID) else {
			return 72.0
		}
		
		let physicalSize = CGDisplayScreenSize (displayID)
		let widthInInches = physicalSize.width / 25.4
		let pixelWidth = CGFloat (mode.pixelWidth)
		let dpi = pixelWidth / widthInInches
		
		// Odd scalar I needed for my display.
		return dpi / 2.0
	}
	
	private func aspectDelta (image: NSImage) -> Int {
		return Int (round (image.size.width - image.size.height))
	}
	
	private func adjustedImage (sourceImage: NSImage, pan: Double) -> NSImage? {
		var finalImage: NSImage?
		let outEdge = 3 * outputImageDPI
		let bitsPerComponent = 8
		let bytesPerRow = Int (floor (outEdge) * 4)
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let srcWidth = sourceImage.size.width
		let srcHeight = sourceImage.size.height
		let srcEdge = min (srcWidth, srcHeight)
		
		guard let context = CGContext (data: nil, width: Int (floor (outEdge)), height: Int (floor (outEdge)), bitsPerComponent: bitsPerComponent,
				bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
			print("Unable to create context")
			return finalImage
		}
		
		// Fill the context with a white background
		context.setFillColor (NSColor.white.cgColor)
		context.fill (CGRect (x: 0, y: 0, width: outEdge, height: outEdge))
		
		context.saveGState()
		
		let rotationAngle = straighten * 0.15
		
		// Calculate the scale factor to fill the destination context
		let straightenScale = 1.0 / (abs (cos (rotationAngle)) + abs (sin (rotationAngle)))
		let scaleFactor = Double (outEdge) / (srcEdge * straightenScale);
		
		// Apply the transformations to the context
		context.saveGState()
		
		// Apply the scaling
		context.scaleBy(x: scaleFactor, y: scaleFactor)
		
		// Move origin to the center of the destination context
		context.translateBy(x: outEdge / 2 / scaleFactor, y: outEdge / 2 / scaleFactor)
		
		// Apply the rotation
		context.rotate(by: rotationAngle)
		
		// Move origin back to the center of the source image
		context.translateBy(x: -srcEdge / 2, y: -srcEdge / 2)
		
		// Allow for pan.
		let halfDelta = round (Double (aspectDelta (image: sourceImage)) / -2.0)
		context.translateBy (x: halfDelta + pan, y: 0)
		
		// Draw the image into the context
		if let cgImage = sourceImage.cgImage (forProposedRect: nil, context: nil, hints: nil) {
			context.draw (cgImage, in: CGRect (origin: .zero, size: NSSize (width: srcWidth, height: srcHeight)))
		}
		
		context.restoreGState()
		
		// Create an image from the context
		guard let cgImage = context.makeImage() else {
			print("Unable to create CGImage")
			return finalImage
		}
		
		finalImage = NSImage(cgImage: cgImage, size: NSSize (width: outEdge, height: outEdge))
		return finalImage
	}
	
	private func registerCustomFont () {
		guard let fontURL = Bundle.main.url (forResource: "SpecialElite", withExtension: "ttf") else {
			print ("Failed to find font file.")
			return
		}
		
		let fontDataProvider = CGDataProvider (url: fontURL as CFURL)
		guard let font = CGFont (fontDataProvider!) else {
			print ("Failed to create CGFont.")
			return
		}
		
		var error: Unmanaged<CFError>?
		if !CTFontManagerRegisterGraphicsFont (font, &error) {
			let errorDescription = CFErrorCopyDescription (error!.takeRetainedValue ())
			print ("Failed to register font: \(String(describing: errorDescription))")
		}
	}
	
	private func customFont (size: CGFloat) -> NSFont? {
		guard let font = NSFont(name: "Special Elite", size: size) else {
			print("Failed to create NSFont.")
			return nil
		}
		return font
	}
	
	private func drawText (in context: CGContext, text: String, centeredOn point: CGPoint, color: NSColor) {
		// Save the current graphics state
		context.saveGState()
		
		// Create an attributed string with the text and attributes.
		guard let font = customFont (size: 10 * outputImageDPI / 72.0) else {
			return
		}
		let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
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

	private func compositeImage (leftImage: NSImage, rightImage: NSImage) -> NSImage? {
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
		var maskImage = NSImage.Name("CardMask")
		if (true) {
			maskImage = NSImage.Name("CardMaskLight")
		}
		if let maskImage = NSImage (named: maskImage), let maskCGImage = maskImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
			context.draw (maskCGImage, in: CGRect (x: 0, y: 0, width: 7.0 * outputImageDPI, height: 3.5 * outputImageDPI))
		}
		let xOffset = -0.003
		let yOffset = -0.003
		let xSeparation = -0.003	// 0.005
		var textColor = NSColor.white
		if (true) {
			textColor = NSColor.black.withAlphaComponent (0.55)
		}
		let shadowColor = NSColor.black.withAlphaComponent (0.25)
		drawText (in: context, text: textFieldValue, centeredOn: CGPoint (x: outputImageDPI * (2.0 + xOffset), y: outputImageDPI * (0.2 + yOffset)),
				color: shadowColor)
		drawText (in: context, text: textFieldValue, centeredOn: CGPoint (x: outputImageDPI * (5.0 + xOffset), y: outputImageDPI * (0.2 + yOffset)),
				color: shadowColor)
		drawText (in: context, text: textFieldValue, centeredOn: CGPoint (x: outputImageDPI * (2.0 + xSeparation), y: outputImageDPI * 0.2),
				color: textColor)
		drawText (in: context, text: textFieldValue, centeredOn: CGPoint (x: outputImageDPI * (5.0 - xSeparation), y: outputImageDPI * 0.2),
				color: textColor)
		
		// Create an image from the context
		guard let cgImage = context.makeImage() else {
			print("Unable to create CGImage")
			return finalImage
		}
		
		finalImage = NSImage(cgImage: cgImage, size: NSSize(width: Int (width), height: Int (height)))
		return finalImage
	}
	
	private func stereogram () -> NSImage? {
		// Get left and right image from the document.
		guard let srcLeftImage = document.leftImage, let srcRightImage = document.rightImage else {
			return nil;
		}
		
		// Determine left and right pan values.
		let aspectScale = Double (aspectDelta (image: srcLeftImage)) / 2.0
		let minPan = -aspectScale
		let maxPan = aspectScale
		let leftPan = min (max ((pan * aspectScale) - (separation * (aspectScale / 4.0)), minPan), maxPan)
		let rightPan = min (max ((pan * aspectScale) + (separation * (aspectScale / 4.0)), minPan), maxPan)
		
		// Create scaled and panned left and right images — then generate the final composite image.
		if let leftImage = adjustedImage (sourceImage: srcLeftImage, pan: Double(leftPan)),
				let rightImage = adjustedImage (sourceImage: srcRightImage, pan: Double(rightPan)) {
			return compositeImage (leftImage: leftImage, rightImage: rightImage)
		} else {
			return nil
		}
	}
	
	private func exportImage() {
		if let image = stereogram () {
			// Show the save panel
			let savePanel = NSSavePanel()
			savePanel.nameFieldStringValue = textFieldValue
			savePanel.allowedContentTypes = [UTType.jpeg]
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
					.onAppear {
						registerCustomFont()
					}
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
					Text("Straighten")
					Slider(value: $straighten, in: -1...1)
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
					Text("Title:")
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
