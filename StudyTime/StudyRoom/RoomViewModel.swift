//
//  ViewModel.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI
import Combine



class RoomViewModel: ObservableObject {
    @Published var
    remainingTime: Int = 0
    @Published var isRunning: Bool = false
    @Published var isStudyMode: Bool = true

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
        // 残り時間が0の場合のみリセット
        if remainingTime == 0 {
            remainingTime = isStudyMode ? studyMinutes * 60 : breakMinutes * 60
        }
        isRunning = true


        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in guard let self = self else { return }

            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
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
    
    func resetTimer(){
        stopTimer()
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
}
