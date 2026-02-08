//
//  ViewModel.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI
import Combine
import SwiftData

class RoomViewModel: ObservableObject {
    @Published var
    remainingTime: Int = 0
    @Published var isRunning: Bool = false
    @Published var isStudyMode: Bool = true

    // 勉強セッションの開始時刻
    private var sessionStartTime: Date?
    // ModelContext（SwiftDataに保存するため）
    var modelContext: ModelContext?
    // 現在進行中のセッション
    private var currentSession: StudySession?

    @Published var studyMinutes: Int = 25 {
        didSet {
            UserDefaults.standard.set(studyMinutes, forKey: "studyMinutes")
        }
    }
    @Published var breakMinutes: Int = 5 {
        didSet {
            UserDefaults.standard.set(breakMinutes, forKey: "breakMinutes")
        }
    }

    // 勉強時間の時間部分（0-3時間）
    var studyHours: Int {
        get { studyMinutes / 60 }
        set { studyMinutes = newValue * 60 + studyMinutesOnly }
    }

    // 勉強時間の分部分（0, 10, 20, 30, 40, 50）
    var studyMinutesOnly: Int {
        get { studyMinutes % 60 }
        set { studyMinutes = studyHours * 60 + newValue }
    }

    // 休憩時間の時間部分（0-1時間）
    var breakHours: Int {
        get { breakMinutes / 60 }
        set { breakMinutes = newValue * 60 + breakMinutesOnly }
    }

    // 休憩時間の分部分（0, 10, 20, 30, 40, 50）
    var breakMinutesOnly: Int {
        get { breakMinutes % 60 }
        set { breakMinutes = breakHours * 60 + newValue }
    }

    @Published var studySubject: String = "数学" {
        didSet {
            UserDefaults.standard.set(studySubject, forKey: "studySubject")
        }
    }
    @Published var subjectPresets: [String] = ["数学", "英語", "国語", "理科", "社会", "プログラミング"] {
        didSet {
            UserDefaults.standard.set(subjectPresets, forKey: "subjectPresets")
        }
    }
    @Published var showSubjectSettings: Bool = false
    @Published var showTimeSettings: Bool = false
    @Published var newSubject: String = ""

    private var timer: Timer?

    init() {
        // 保存された設定を読み込む
        if let savedSubject = UserDefaults.standard.string(forKey: "studySubject") {
            self.studySubject = savedSubject
        }
        if let savedPresets = UserDefaults.standard.array(forKey: "subjectPresets") as? [String], !savedPresets.isEmpty {
            self.subjectPresets = savedPresets
        }
        let savedStudyMinutes = UserDefaults.standard.integer(forKey: "studyMinutes")
        if savedStudyMinutes > 0 {
            self.studyMinutes = savedStudyMinutes
        }
        let savedBreakMinutes = UserDefaults.standard.integer(forKey: "breakMinutes")
        if savedBreakMinutes > 0 {
            self.breakMinutes = savedBreakMinutes
        }
    }

    func addSubjectPreset(_ subject: String) {
        if !subjectPresets.contains(subject) && !subject.isEmpty {
            subjectPresets.append(subject)
        }
    }

    func removeSubjectPreset(_ subject: String) {
        subjectPresets.removeAll { $0 == subject }
    }

    func updateSubjectInPresets(from oldSubject: String, to newSubject: String) {
        if let index = subjectPresets.firstIndex(of: oldSubject) {
            subjectPresets[index] = newSubject
        }
    }
    
    func startTimer() {
        print("startTimer 呼び出し - isStudyMode: \(isStudyMode), remainingTime: \(remainingTime)")

        // 残り時間が0の場合のみリセット
        if remainingTime == 0 {
            remainingTime = isStudyMode ? studyMinutes * 60 : breakMinutes * 60
            // 勉強モードの場合、セッションを作成
            if isStudyMode {
                print("勉強モードなのでセッション作成します")
                createNewSession()
            }
        }
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in guard let self = self else { return }

            if self.remainingTime > 0 {
                self.remainingTime -= 1
                // 勉強モードの場合、進行中のセッションを更新
                if self.isStudyMode {
                    self.updateCurrentSession()
                }
            } else {
                self.completeSession()
                self.stopTimer()
                self.isStudyMode.toggle()
            }
        }
    }
    func stopTimer() {
        timer?.invalidate()
//        タイマーを無効にする
        timer = nil
        isRunning = false
    }

    func resetTimer() {
        stopTimer()

        // 進行中のセッションを削除
        if let session = currentSession, let context = modelContext {
            context.delete(session)
            do {
                try context.save()
                print("セッションを削除しました")
            } catch {
                print("削除エラー: \(error)")
            }
            currentSession = nil
            sessionStartTime = nil
        }

        remainingTime = isStudyMode ? studyMinutes * 60 : breakMinutes * 60
    }
    
    var timeString: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: CGFloat {
        let totalTime = isStudyMode ? studyMinutes * 60 : breakMinutes * 60
        guard totalTime > 0 else { return 0 }
        return CGFloat(remainingTime) / CGFloat(totalTime)
    }

    // 新しいセッションを作成
    private func createNewSession() {
        print("createNewSession 呼び出し - modelContext: \(modelContext != nil ? "あり" : "なし")")

        guard let context = modelContext else {
            print("❌ modelContextがnilです！")
            return
        }

        let startTime = Date()
        sessionStartTime = startTime

        let session = StudySession(
            subject: studySubject,
            durationSeconds: 0,
            startTime: startTime,
            endTime: startTime
        )

        context.insert(session)
        currentSession = session

        do {
            try context.save()
            print("✅ 新しいセッションを作成しました: \(studySubject)")
        } catch {
            print("❌ セッション作成エラー: \(error)")
        }
    }

    // 進行中のセッションを更新
    private func updateCurrentSession() {
        guard let session = currentSession,
              let context = modelContext else {
            return
        }

        // 経過時間を計算
        let elapsedSeconds = studyMinutes * 60 - remainingTime
        session.durationSeconds = elapsedSeconds
        session.endTime = Date()

        do {
            try context.save()
        } catch {
            print("セッション更新エラー: \(error)")
        }
    }

    // 勉強セッションを完了
    private func completeSession() {
        guard isStudyMode,
              let session = currentSession,
              let context = modelContext else {
            return
        }

        // 最終的な時間を設定
        let totalSeconds = studyMinutes * 60
        session.durationSeconds = totalSeconds
        session.endTime = Date()

        do {
            try context.save()
            print("勉強セッションを完了しました: \(studySubject), \(totalSeconds)秒")
        } catch {
            print("保存エラー: \(error)")
        }

        // セッションをリセット
        sessionStartTime = nil
        currentSession = nil
    }
}
