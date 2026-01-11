//
//  StudyRoomView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI


struct StudyRoomView: View {
    @EnvironmentObject var viewModel: RoomViewModel

    var body: some View {
        ZStack {
            // 背景色
            Color(UIColor(hex: "c8d8e6"))
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // ヘッダー
                VStack(spacing: 8) {
                    Text(viewModel.isStudyMode ? "勉強時間" : "休憩時間")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)

                    // 科目表示
                    if viewModel.isStudyMode {
                        Button(action: {
                            viewModel.showSubjectSettings = true
                        }) {
                            HStack(spacing: 4) {
                                Text(viewModel.studySubject)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.secondary)
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.top, 40)

                // アバター
                Image("tameshi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .padding(.vertical, 20)

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
                        .frame(width: 140, height: 55)
                        .background(Color.white)
                        .foregroundColor(.primary)
                        .cornerRadius(15)
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
                        .frame(width: 140, height: 55)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(15)
                    }
                }

                // 時間表示
                HStack(spacing: 8) {
                    Text(viewModel.timeString)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(viewModel.isRunning ? "実行中" : "一時停止中")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                }
                .padding(.vertical, 10)

        

                // 設定セクション
                VStack(spacing: 16) {
                    Text("設定")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 勉強時間設定
                    HStack {
                        Image(systemName: "book.fill")
                            .frame(width: 30)
                        Text("勉強時間")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Stepper("\(viewModel.studyMinutes)分", value: $viewModel.studyMinutes, in: 1...60)
                            .labelsHidden()
                        Text("\(viewModel.studyMinutes)分")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)

                    // 休憩時間設定
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .frame(width: 30)
                        Text("休憩時間")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Stepper("\(viewModel.breakMinutes)分", value: $viewModel.breakMinutes, in: 1...30)
                            .labelsHidden()
                        Text("\(viewModel.breakMinutes)分")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $viewModel.showSubjectSettings) {
            SubjectSettingsView(viewModel: viewModel)
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

#Preview {
    StudyRoomView()
        .environmentObject(RoomViewModel())
}
