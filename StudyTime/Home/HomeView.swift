//
//  HomeView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var allSessions: [StudySession]

    // 今日のセッションのみ取得
    private var todaySessions: [StudySession] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let filtered = allSessions.filter { session in
            session.startTime >= today && session.startTime < tomorrow
        }

        print("📊 todaySessions - 全体: \(allSessions.count)件, 今日: \(filtered.count)件")
        for session in filtered {
            print("  - \(session.subject): \(session.durationSeconds)秒")
        }

        return filtered
    }

    // 今日の勉強時間（秒）
    private var todayStudySeconds: Int {
        todaySessions.reduce(0) { $0 + $1.durationSeconds }
    }

    // 今日の勉強時間を00:00:00形式で表示
    private var todayStudyTimeText: String {
        let hours = todayStudySeconds / 3600
        let minutes = (todayStudySeconds % 3600) / 60
        let seconds = todayStudySeconds % 60

        // デバッグ用
        print("全セッション数: \(allSessions.count)")
        print("今日のセッション数: \(todaySessions.count)")
        print("今日の合計秒数: \(todayStudySeconds)")

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(UIColor(hex: "c8d8e6"))
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    // 上部：時間表示セクション
                    VStack(spacing: 8) {
                        Text("今日の勉強時間")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)

                        Text(todayStudyTimeText)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.primary)
                            .tracking(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)

                    // 日付表示
                    Text(viewModel.todayDateText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    Spacer()

                    // 勉強をするボタン
                    NavigationLink(destination: StudyRoomView().environmentObject(viewModel.roomViewModel)) {
                        Text("勉強をする")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 20)

                    // キャラクター画像
                    Image("tameshi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)

                    Spacer()

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
                                    Text(viewModel.goalTimeText)
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
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $viewModel.showGoalSettings) {
            GoalSettingsView(viewModel: viewModel)
        }
    }

}

// 目標設定画面
struct GoalSettingsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(UIColor(hex: "c8d8e6"))
                    .ignoresSafeArea()

            Form {
                Section(header: Text("目標")) {
                    TextField("目標を入力", text: $viewModel.goalText)
                }

                Section(header: Text("目標時間")) {
                    VStack(spacing: 16) {
                        // 合計表示
                        HStack {
                            Text("合計")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.goalMinutes)分")
                                .font(.system(size: 18, weight: .semibold))
                        }

                        Divider()

                        // 時間設定
                        HStack {
                            Text("時間")
                                .foregroundColor(.secondary)
                            Spacer()
                            Stepper("", value: Binding(
                                get: { viewModel.goalHours },
                                set: { viewModel.goalHours = $0 }
                            ), in: 0...12)
                            .labelsHidden()
                            Text("\(viewModel.goalHours)時間")
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 70, alignment: .trailing)
                        }

                        // 分設定
                        HStack {
                            Text("分")
                                .foregroundColor(.secondary)
                            Spacer()
                            Stepper("", onIncrement: {
                                viewModel.goalMinutesOnly = (viewModel.goalMinutesOnly + 10) % 60
                            }, onDecrement: {
                                viewModel.goalMinutesOnly = (viewModel.goalMinutesOnly - 10 + 60) % 60
                            })
                            .labelsHidden()
                            Text("\(viewModel.goalMinutesOnly)分")
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 70, alignment: .trailing)
                        }
                    }
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
