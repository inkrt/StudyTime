//
//  HomeView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        Text("今日の勉強時間")
        Text("目標")
        
    }
}

#Preview {
    HomeView()
        .environmentObject(ViewModel())
}
