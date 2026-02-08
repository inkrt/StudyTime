//
//  StudyRoomView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI
import SwiftData

struct StudyRoomView: View {
    @EnvironmentObject var viewModel: RoomViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            // 背景色
            Color(UIColor(hex: "c8d8e6"))
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // ヘッダーと設定ボタン
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.showTimeSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }

                Spacer()

                // タイトルと科目
                VStack(spacing: 12) {
                    Text(viewModel.isStudyMode ? "勉強時間" : "休憩時間")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)

                    // 科目表示
                    if viewModel.isStudyMode {
                        Button(action: {
                            viewModel.showSubjectSettings = true
                        }) {
                            HStack(spacing: 4) {
                                Text(viewModel.studySubject)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                }

                Spacer()

                // 時間表示
                VStack(spacing: 8) {
                    Text(viewModel.timeString)
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(viewModel.isRunning ? "実行中" : "一時停止中")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // アバター
                Image("tameshi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())

                Spacer()

                // コントロールボタン
                HStack(spacing: 20) {
                    // 開始/停止ボタン
                    Button(action: {
                        if viewModel.isRunning {
                            viewModel.stopTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            Text(viewModel.isRunning ? "停止" : "開始")
                                .fontWeight(.semibold)
                        }
                        .frame(width: 140, height: 50)
                        .background(Color.white)
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }

                    // リセットボタン
                    Button(action: {
                        viewModel.resetTimer()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("リセット")
                                .fontWeight(.semibold)
                        }
                        .frame(width: 140, height: 50)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $viewModel.showSubjectSettings) {
            SubjectSettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showTimeSettings) {
            TimeSettingsView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.modelContext = modelContext
            print("StudyRoomView: modelContextを設定しました - \(modelContext)")
        }
    }
}

// 科目設定画面
struct SubjectSettingsView: View {
    @ObservedObject var viewModel: RoomViewModel
    @Environment(\.dismiss) var dismiss
    @State private var originalSubject: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(UIColor(hex: "c8d8e6"))
                    .ignoresSafeArea()

            VStack(spacing: 20) {
                // カスタム入力
                VStack(alignment: .leading, spacing: 8) {
                    Text("科目名")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack {
                        TextField("科目を入力", text: $viewModel.studySubject)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 18))
                            .focused($isTextFieldFocused)
                            .onAppear {
                                originalSubject = viewModel.studySubject
                            }
                            .onChange(of: isTextFieldFocused) { oldValue, newValue in
                                if newValue {
                                    // フォーカスが当たったときに元の値を記録
                                    originalSubject = viewModel.studySubject
                                } else {
                                    // フォーカスが外れたときに更新をチェック
                                    if !originalSubject.isEmpty && originalSubject != viewModel.studySubject {
                                        viewModel.updateSubjectInPresets(from: originalSubject, to: viewModel.studySubject)
                                    }
                                }
                            }
                    }
                }
                .padding()

                Divider()

                // プリセット選択
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("よく使う科目")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("長押しで削除")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.subjectPresets, id: \.self) { subject in
                                Button(action: {
                                    viewModel.studySubject = subject
                                }) {
                                    HStack {
                                        Text(subject)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if viewModel.studySubject == subject {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color(UIColor(hex: "c8d8e6")))
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.removeSubjectPreset(subject)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                            }

                            // 新しい科目を追加
                            HStack {
                                TextField("新しい科目を追加", text: $viewModel.newSubject)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 16))

                                Button(action: {
                                    viewModel.addSubjectPreset(viewModel.newSubject)
                                    viewModel.newSubject = ""
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color(UIColor(hex: "c8d8e6")))
                                }
                                .disabled(viewModel.newSubject.isEmpty)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            }
            .navigationTitle("勉強科目")
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

// 時間設定画面
struct TimeSettingsView: View {
    @ObservedObject var viewModel: RoomViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(UIColor(hex: "c8d8e6"))
                    .ignoresSafeArea()

                Form {
                    // 勉強時間設定
                    Section(header: Text("勉強時間")) {
                        VStack(spacing: 16) {
                            // 合計表示
                            HStack {
                                Text("合計")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(viewModel.studyMinutes)分")
                                    .font(.system(size: 18, weight: .semibold))
                            }

                            Divider()

                            // 時間設定
                            HStack {
                                Text("時間")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Stepper("", value: Binding(
                                    get: { viewModel.studyHours },
                                    set: { viewModel.studyHours = $0 }
                                ), in: 0...3)
                                .labelsHidden()
                                Text("\(viewModel.studyHours)時間")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 70, alignment: .trailing)
                            }

                            // 分設定
                            HStack {
                                Text("分")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Stepper("", onIncrement: {
                                    viewModel.studyMinutesOnly = (viewModel.studyMinutesOnly + 10) % 60
                                }, onDecrement: {
                                    viewModel.studyMinutesOnly = (viewModel.studyMinutesOnly - 10 + 60) % 60
                                })
                                .labelsHidden()
                                Text("\(viewModel.studyMinutesOnly)分")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 70, alignment: .trailing)
                            }
                        }
                    }

                    // 休憩時間設定
                    Section(header: Text("休憩時間")) {
                        VStack(spacing: 16) {
                            // 合計表示
                            HStack {
                                Text("合計")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(viewModel.breakMinutes)分")
                                    .font(.system(size: 18, weight: .semibold))
                            }

                            Divider()

                            // 時間設定
                            HStack {
                                Text("時間")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Stepper("", value: Binding(
                                    get: { viewModel.breakHours },
                                    set: { viewModel.breakHours = $0 }
                                ), in: 0...1)
                                .labelsHidden()
                                Text("\(viewModel.breakHours)時間")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 70, alignment: .trailing)
                            }

                            // 分設定
                            HStack {
                                Text("分")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Stepper("", onIncrement: {
                                    viewModel.breakMinutesOnly = (viewModel.breakMinutesOnly + 10) % 60
                                }, onDecrement: {
                                    viewModel.breakMinutesOnly = (viewModel.breakMinutesOnly - 10 + 60) % 60
                                })
                                .labelsHidden()
                                Text("\(viewModel.breakMinutesOnly)分")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 70, alignment: .trailing)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("時間設定")
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
    StudyRoomView()
        .environmentObject(RoomViewModel())
}
