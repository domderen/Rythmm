//
//  DirectoryPicker.swift
//  Rythmm
//
//  Created by Dominik Deren on 11/01/2024.
//

import SwiftUI

struct DirectoryPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        controller.allowsMultipleSelection = false
        controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    func makeCoordinator() -> DirectoryPickerCoordinator {
        DirectoryPickerCoordinator()
    }
    
}
class DirectoryPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        //        player.readDir(url: url)
        
        do {
            // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                return
            }
            
            
            // Make sure you release the security-scoped resource when you finish.
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
//            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
//                
//            try bookmarkData.write(to: BasePlayer.fileURL())
//            
            
            // Use file coordination for reading and writing any of the URL’s content.
            var error: NSError? = nil
            NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { (url) in
                
                let keys : [URLResourceKey] = [.nameKey, .isDirectoryKey]
                
                // Get an enumerator for the directory's content.
                guard let fileList =
                        FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
                    Swift.debugPrint("*** Unable to access the contents of \(url.path) ***\n")
                    return
                }
                
                for case let file as URL in fileList {
                    Swift.debugPrint("chosen file: \(file.lastPathComponent)")
                    // Start accessing the content's security-scoped URL.
                    guard file.startAccessingSecurityScopedResource() else {
                        // Handle the failure here.
                        continue
                    }
                    
                    
                    // Do something with the file here.
                    Swift.debugPrint("chosen file: \(file.lastPathComponent)")
                    
                    // Make sure you release the security-scoped resource when you finish.
                    file.stopAccessingSecurityScopedResource()
                }
            }
        } catch let error {
            print("Got an error in documentPicker: \(error)")
        }
    }
}
