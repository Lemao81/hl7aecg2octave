//
//  ContentViewModel.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 09.07.22.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

class ContentViewModel: ObservableObject {
    func handleHL7aECGParsing() {
        if let xmlUrl = getHL7aECGFileUrl() {
            let parserDelegate = HL7aECGXmlParserDelegate()
            parserDelegate.parse(url: xmlUrl) { (sequences: [HL7aECGSequence]) in
                
            }
        }
    }
    
    func getHL7aECGFileUrl() -> URL? {
        let dialog = NSOpenPanel();
        dialog.title = "Select HL7-aECG xml file";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;
        dialog.allowedContentTypes = [.xml]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK){
            return dialog.url;
        }
        
        return nil;
    }
}
