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
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // ヘッダー
                Text(viewModel.isStudyMode ? "勉強時間" : "休憩時間")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(viewModel.isStudyMode ? .blue : .green)
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
                            viewModel.isStudyMode ? Color.blue : Color.green,
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
                        .background(viewModel.isStudyMode ? Color.blue : Color.green)
                        .foregroundColor(.white)
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
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("勉強時間")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Stepper("\(viewModel.studyMinutes)分", value: $viewModel.studyMinutes, in: 1...60)
                            .labelsHidden()
                        Text("\(viewModel.studyMinutes)分")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)

                    // 休憩時間設定
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        Text("休憩時間")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Stepper("\(viewModel.breakMinutes)分", value: $viewModel.breakMinutes, in: 1...30)
                            .labelsHidden()
                        Text("\(viewModel.breakMinutes)分")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
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
    }
}

#Preview {
    StudyRoomView()
        .environmentObject(RoomViewModel())
}
