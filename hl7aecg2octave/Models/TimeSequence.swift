//
//  HL7aECGTimeSequence.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 10.07.22.
//

import Foundation

struct TimeSequence {
    let code: String
    let type: String
    let increment: Float
    let unit: String
    
    init(code: String? = "", type: String? = "", increment: String? = "", unit: String? = "") {
        self.code = code ?? ""
        self.type = type ?? ""
        self.increment = increment != nil && !increment!.isEmpty ? Float(increment!)! : 0
        self.unit = unit ?? ""
    }
}
