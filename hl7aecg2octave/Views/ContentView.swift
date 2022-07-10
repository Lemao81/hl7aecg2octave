//
//  ContentView.swift
//  hl7aecg2octave
//
//  Created by JuergenReiser on 09.07.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Button(
                action: viewModel.handleHL7aECGParsing,
                label: {
                    Text("Select HL7-aECG xml")
                        .padding(4.0)
                })
        }
        .frame(width: 300.0, height: 300.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ContentViewModel())
    }
}
