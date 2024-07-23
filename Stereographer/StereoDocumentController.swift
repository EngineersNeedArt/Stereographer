import Cocoa

class StereoDocumentController: NSDocumentController {
	override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
		super.openDocument(withContentsOf: url, display: displayDocument, completionHandler: completionHandler)
	}
}
