//
//  HL7aECGXmlParserDelegate.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 09.07.22.
//

import Foundation

class XmlParserDelegate: NSObject, XMLParserDelegate {
    private var isDigits: Bool = false
    private var sequences: [SequenceDto] = []
    private var currentSequence: SequenceDto? = nil
    private var onCompleteHandler: (([SequenceDto]) -> Void)? = nil
    
    func parse(url: URL, onComplete: (([SequenceDto]) -> Void)?) {
        onCompleteHandler = onComplete
        let parser = XMLParser(contentsOf: url)
        parser?.delegate = self
        parser?.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName.uppercased() {
            case XmlTags.sequence:
                currentSequence = SequenceDto()
            case XmlTags.code:
                currentSequence?.code = attributeDict[XmlAttributes.code]
            case XmlTags.value:
                currentSequence?.type = attributeDict[XmlAttributes.type]
            case XmlTags.increment:
                currentSequence?.timeIncrement = attributeDict[XmlAttributes.value]
                currentSequence?.timeUnit = attributeDict[XmlAttributes.unit]
            case XmlTags.scale:
                currentSequence?.signalScale = attributeDict[XmlAttributes.value]
                currentSequence?.signalUnit = attributeDict[XmlAttributes.unit]
            case XmlTags.digits:
                isDigits = true
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (isDigits) {
            if (currentSequence != nil && currentSequence?.digits == nil) {
                currentSequence?.digits = ""
            }
            
            currentSequence?.digits! += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName.uppercased() {
            case XmlTags.sequence:
                if let currentSequenceNonNil = currentSequence {
                    sequences.append(currentSequenceNonNil)
                    currentSequence = nil
                }
            case XmlTags.digits:
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
