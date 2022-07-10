//
//  HL7aECGSignalSequence.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 10.07.22.
//

import Foundation

struct HL7aECGSignalSequence {
    let code: String
    let type: String
    let scale: Float
    let unit: String
    let digits: [Int]
    
    init(code: String? = "", type: String? = "", scale: String? = "", unit: String? = "", digits: String? = "") {
        self.code = code ?? ""
        self.type = type ?? ""
        self.scale = scale != nil && !scale!.isEmpty ? Float(scale!)! : 0
        self.unit = unit ?? ""
        self.digits = digits != nil ? digits!.split(separator: " ").map({ Int($0)! }) : []
    }
}
