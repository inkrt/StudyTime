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

            StudyView()
                .tabItem {
                    Label("study", systemImage: "pencil")
                }

            StudyDtailView()
                .tabItem {
                    Label("Detail", systemImage: "list.star")
                }
        }
    }
}

#Preview {
    ContentView()
}
