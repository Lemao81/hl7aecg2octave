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
            let parserDelegate = XmlParserDelegate()
            parserDelegate.parse(url: xmlUrl) { (sequenceDtos: [SequenceDto]) in
                let timeSequence = self.getTimeSequence(dtos: sequenceDtos)
                let signalSequences = self.getSignalSequences(dtos: sequenceDtos)
                let chartData = self.getChartData(timeSequence: timeSequence, signalSequences: signalSequences)
                self.promptFolderAndSaveFiles(chartData: chartData)
            }
        }
    }
    
    func getHL7aECGFileUrl() -> URL? {
        let dialog = NSOpenPanel()
        dialog.title = "Select HL7-aECG xml file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedContentTypes = [.xml]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            return dialog.url;
        }
        
        return nil;
    }
    
    func getTimeSequence(dtos: [SequenceDto]) -> TimeSequence {
        if let timeDto = dtos.first(where: { $0.type?.equalsIgnoreCase(other: "GLIST_TS") ?? false }) {
            return TimeSequence(code: timeDto.code, type: timeDto.type, increment: timeDto.timeIncrement, unit: timeDto.timeUnit)
        }
        
        return TimeSequence()
    }
    
    func getSignalSequences(dtos: [SequenceDto]) -> [SignalSequence] {
        let signalDtos = dtos.filter({ $0.type?.equalsIgnoreCase(other: "SLIST_PQ") ?? false })
        
        return signalDtos.map({ SignalSequence(code: $0.code, type: $0.type, scale: $0.signalScale, unit: $0.signalUnit, digits: $0.digits )})
    }
    
    func getChartData(timeSequence: TimeSequence, signalSequences: [SignalSequence]) -> [ChartData] {
        return signalSequences.map({
            let signalSequence = $0
            let deltaT = getDeltaT(sequence: timeSequence)
            let scaleFactor = getScaleFactor(sequence: signalSequence)
            var points: [(x: Float, y: Float)] = []
            for (index, digit) in signalSequence.digits.enumerated() {
                points.append((Float(index) * deltaT, Float(digit) * scaleFactor))
            }
            
            return ChartData(name: signalSequence.code, timeUnit: timeSequence.unit, signalUnit: signalSequence.unit, points: points)
        })
    }
    
    func getDeltaT(sequence: TimeSequence) -> Float {
        switch sequence.unit {
            case "s":
                return Float(sequence.increment) * Float(1)
            default:
                // TODO throw error
                return Float(sequence.increment) * Float(1)
        }
    }
    
    func getScaleFactor(sequence: SignalSequence) -> Float {
        return sequence.scale
    }
    
    func promptFolderAndSaveFiles(chartData: [ChartData]) {
        let dialog = NSOpenPanel()
        dialog.title = "Select folder to save files"
        dialog.showsResizeIndicator = true
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.begin() { (result) in
            if (result == NSApplication.ModalResponse.OK) {
                if let url = dialog.url {
                    for data in chartData {
                        self.writeChartDataToCsv(chartData: data, folderUrl: url)
                    }
                    // only first + 100000 values since reading in octave take very long time
                    if let firstChartData = chartData.first {
                        self.writeOctaveMFile(csvFileName: "\(firstChartData.name).csv", amountValues: 100000, xLabel: firstChartData.timeUnit, yLabel: firstChartData.signalUnit, folderUrl: url)
                    }
                }
            }
        }
    }
    
    func writeChartDataToCsv(chartData: ChartData, folderUrl: URL) {
        var text = ""
        text.append("dt(\(chartData.timeUnit)),\(chartData.signalUnit)\n")
        for (time, signal) in chartData.points {
            text.append("\(time),\(signal)\n")
        }
        
        let fileName = "\(chartData.name).csv"
        writeFile(fileName: fileName, folderUrl: folderUrl, text: text)
    }
    
    func writeOctaveMFile(csvFileName: String, amountValues: Int, xLabel: String, yLabel: String, folderUrl: URL) {
        var text = "clear all, fclose all\n"
        text.append("fid = fopen('\(csvFileName)', 'r');\n")
        text.append("header = fscanf(fid, '%s, %s', [2 1])\n")
        text.append("A = fscanf(fid, '%f, %f', [2 \(amountValues)])\n")
        text.append("B = A'\n")
        text.append("fclose(fid);\n")
        text.append("x = B(:,1);\n")
        text.append("y = B(:,2);\n")
        text.append("plot(x,y);\n")
        text.append("set (gca, 'linewidth', 1, 'fontsize', 36)\n")
        text.append("xlabel('\(xLabel)');\n")
        text.append("ylabel('\(yLabel)');\n")
        text.append("grid on\n")
        
        writeFile(fileName: "octave_script.m", folderUrl: folderUrl, text: text)
    }
    
    func writeFile(fileName: String, folderUrl: URL, text: String) {
        let fileUrl = folderUrl.appendingPathComponent(fileName)
        do {
            try text.write(to: fileUrl, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write csv file: \(error.localizedDescription)")
        }
    }
}
