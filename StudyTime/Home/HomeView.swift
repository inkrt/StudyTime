//
//  HomeView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView{
        ZStack {
            // 背景色
            Color(UIColor(hex: "e0ffff"))
                .ignoresSafeArea()

        VStack(spacing: 20){
            Image("tameshi")
                .resizable()
                .frame(width: 400, height: 400)

            Text("今日の勉強時間")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)

            // 目標表示
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("目標")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(viewModel.goalText)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)

                        HStack(spacing: 4) {
                            Text("目標時間:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("\(viewModel.goalHours)時間")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    Spacer()

                    // 設定ボタン
                    Button(action: {
                        viewModel.showGoalSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal)


            NavigationLink(destination: StudyRoomView().environmentObject(viewModel.roomViewModel)) {
                Text("勉強をする")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 200, height: 50)
                    .background(Color.white)
                    .cornerRadius(12)
            }
//                    その後にどの友達とやる？みたいなのを追加したい

            }
        }
        }
        .sheet(isPresented: $viewModel.showGoalSettings) {
            GoalSettingsView(goalText: $viewModel.goalText, goalHours: $viewModel.goalHours)
        }
    }

}

// 目標設定画面
struct GoalSettingsView: View {
    @Binding var goalText: String
    @Binding var goalHours: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(UIColor(hex: "e0ffff"))
                    .ignoresSafeArea()

            Form {
                Section(header: Text("目標")) {
                    TextField("目標を入力", text: $goalText)
                }

                Section(header: Text("目標時間")) {
                    Stepper("\(goalHours)時間", value: $goalHours, in: 1...12)
                        .font(.system(size: 18, weight: .medium))
                }
            }
            .scrollContentBackground(.hidden)
            }
            .navigationTitle("目標設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    HomeView()
     
}
