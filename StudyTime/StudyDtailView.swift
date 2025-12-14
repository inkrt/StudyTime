//
//  StudyDtailView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI

struct StudyDtailView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        Text("詳細")
    }
}

#Preview {
    StudyDtailView()
        .environmentObject(ViewModel())
}
