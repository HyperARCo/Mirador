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
            let filePath = Bundle.main.path(forResource: "greenwich", ofType: ".json")!

            if let anchor = LocationAnchor.anchorFromFile(atPath: filePath) {
                let model = MiradorViewModel(locationAnchor: anchor)
                
                MiradorViewContainer(model: model)
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
