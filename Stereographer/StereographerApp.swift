//
//  StereographerApp.swift
//  Stereographer
//
//  Created by John Calhoun on 7/19/24.
//

import SwiftUI


@main
struct MyApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	var body: some Scene {
		DocumentGroup(newDocument: StereoImageDocument()) { file in
			ContentView(document: file.$document)
		}
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	func application(_ application: NSApplication, open urls: [URL]) {
		for url in urls {
			// Handle opening each file
			let _ = NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { (document, documentWasAlreadyOpen, error) in
				if let error = error {
					print("Error opening document: \(error)")
				}
			}
		}
	}
}
