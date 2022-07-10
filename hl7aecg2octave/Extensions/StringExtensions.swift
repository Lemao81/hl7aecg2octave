//
//  StringExtensions.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 09.07.22.
//

import Foundation

extension String {
    func equalsIgnoreCase(other: String) -> Bool {
        return other.caseInsensitiveCompare(self) == .orderedSame
    }
}
