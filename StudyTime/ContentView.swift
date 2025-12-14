//
//  ContentView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/13.
//

import SwiftUI

struct ContentView: View {
    @State var selection = 1
    var body: some View {
        TabView(selection: $selection) {

                    HomeView()
                        .tabItem {
                            Label("home", systemImage: "house")
                        }
                        .tag(1)

                    StudyDtailView()
                        .tabItem {
                            Label("Detail", systemImage: "list.star")
                        }
                        .tag(2)

                }
    }

}

#Preview {
    ContentView()
}
