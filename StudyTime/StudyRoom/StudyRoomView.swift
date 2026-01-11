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
            Color(UIColor(hex: "e6eef5"))
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

                Spacer()

                // 円形タイマー
                ZStack {
                    // 背景円
                    Circle()
                        .stroke(
                            Color.gray.opacity(0.2),
                            lineWidth: 20
                        )

                    // プログレス円
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            Color(UIColor(hex: "e6eef5")),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: viewModel.progress)


                    Image("tameshi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                }
                .frame(width: 280, height: 280)
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
                .padding(.horizontal)

                Spacer()

                // 設定セクション
                VStack(spacing: 16) {
                    Text("設定")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 勉強時間設定
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(Color(UIColor(hex: "e6eef5")))
                            .frame(width: 30)
                        Text("勉強時間")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Stepper("\(viewModel.studyMinutes)分", value: $viewModel.studyMinutes, in: 1...60)
                            .labelsHidden()
                        Text("\(viewModel.studyMinutes)分")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(UIColor(hex: "e6eef5")))
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)

                    // 休憩時間設定
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(Color(UIColor(hex: "e6eef5")))
                            .frame(width: 30)
                        Text("休憩時間")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Stepper("\(viewModel.breakMinutes)分", value: $viewModel.breakMinutes, in: 1...30)
                            .labelsHidden()
                        Text("\(viewModel.breakMinutes)分")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(UIColor(hex: "e6eef5")))
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

    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(UIColor(hex: "e6eef5"))
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
                        Text("左にスワイプで削除")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.subjectPresets, id: \.self) { subject in
                                HStack {
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
                                                    .foregroundColor(Color(UIColor(hex: "e6eef5")))
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
                                        .foregroundColor(Color(UIColor(hex: "e6eef5")))
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
