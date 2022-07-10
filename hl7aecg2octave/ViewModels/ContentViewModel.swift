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
            parserDelegate.parse(url: xmlUrl) { (sequenceDtos: [HL7aECGSequenceDto]) in
                let timeSequence = self.getTimeSequence(dtos: sequenceDtos)
                let signalSequences = self.getSignalSequences(dtos: sequenceDtos)
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
    
    func getTimeSequence(dtos: [HL7aECGSequenceDto]) -> HL7aECGTimeSequence {
        if let timeDto = dtos.first(where: { $0.type?.equalsIgnoreCase(other: "GLIST_TS") ?? false }) {
            return HL7aECGTimeSequence(code: timeDto.code, type: timeDto.type, increment: timeDto.timeIncrement, unit: timeDto.timeUnit)
        }
        
        return HL7aECGTimeSequence()
    }
    
    func getSignalSequences(dtos: [HL7aECGSequenceDto]) -> [HL7aECGSignalSequence] {
        let signalDtos = dtos.filter({ $0.type?.equalsIgnoreCase(other: "SLIST_PQ") ?? false })
        
        return signalDtos.map({ HL7aECGSignalSequence(code: $0.code, type: $0.type, scale: $0.signalScale, unit: $0.signalUnit, digits: $0.digits )})
    }
}
