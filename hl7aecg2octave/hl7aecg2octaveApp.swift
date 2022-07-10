//
//  hl7aecg2octaveApp.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 09.07.22.
//

import SwiftUI

@main
struct hl7aecg2octaveApp: App {
    @StateObject var contentViewModel: ContentViewModel = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contentViewModel)
        }
    }
}
