//
//  HL7aECGChartData.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 10.07.22.
//

import Foundation

struct ChartData {
    let name: String
    let timeUnit: String
    let signalUnit: String
    let points: [(x: Float, y: Float)]
}
