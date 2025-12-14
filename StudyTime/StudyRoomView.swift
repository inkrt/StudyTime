//
//  StudyRoomView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI

struct StudyRoomView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        Text("タイマー")
    }
}

#Preview {
    StudyRoomView()
        .environmentObject(ViewModel())
}
