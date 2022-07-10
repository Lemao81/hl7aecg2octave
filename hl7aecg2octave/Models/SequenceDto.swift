//
//  HL7aECGSequence.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 09.07.22.
//

import Foundation

struct SequenceDto {
    var code: String?
    var type: String?
    var timeIncrement: String?
    var timeUnit: String?
    var signalScale: String?
    var signalUnit: String?
    var digits: String?
}
