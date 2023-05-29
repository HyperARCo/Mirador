//
//  ContentView.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            if let filePath = Bundle.main.path(forResource: "greenwich", ofType: ".json"),
               let anchor = LocationAnchor.anchorFromFile(atPath: filePath) {
                MiradorViewContainer(locationAnchor: anchor)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
