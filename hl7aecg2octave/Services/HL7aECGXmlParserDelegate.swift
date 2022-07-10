//
//  HL7aECGXmlParserDelegate.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 09.07.22.
//

import Foundation

class HL7aECGXmlParserDelegate: NSObject, XMLParserDelegate {
    private var isDigits: Bool = false
    private var sequences: [HL7aECGSequence] = []
    private var currentSequence: HL7aECGSequence? = nil
    private var onCompleteHandler: (([HL7aECGSequence]) -> Void)? = nil
    
    func parse(url: URL, onComplete: (([HL7aECGSequence]) -> Void)?) {
        onCompleteHandler = onComplete
        let parser = XMLParser(contentsOf: url)
        parser?.delegate = self
        parser?.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName.uppercased() {
        case "SEQUENCE":
            currentSequence = HL7aECGSequence()
        case "CODE":
            currentSequence?.code = attributeDict["code"] ?? ""
        case "VALUE":
            currentSequence?.type = attributeDict["xsi:type"] ?? ""
        case "SCALE":
            currentSequence?.scale = attributeDict["value"] ?? ""
            currentSequence?.unit = attributeDict["unit"] ?? ""
        case "DIGITS":
            isDigits = true
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (isDigits) {
            currentSequence?.digits += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName.uppercased() {
        case "SEQUENCE":
            if let currentSequenceNonNil = currentSequence {
                sequences.append(currentSequenceNonNil)
                currentSequence = nil
            }
        case "DIGITS":
            isDigits = false
        default: break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        onCompleteHandler?(sequences)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
