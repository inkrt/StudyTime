//
//  HomeViewModel.swift
//  StudyTime
//
//  Created by 舛水葵 on 2026/01/11.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var goalText: String = "目標未設定" {
        didSet {
            UserDefaults.standard.set(goalText, forKey: "goalText")
        }
    }
    @Published var goalMinutes: Int = 60 {
        didSet {
            UserDefaults.standard.set(goalMinutes, forKey: "goalMinutes")
        }
    }
    @Published var showGoalSettings: Bool = false

    // 連続勉強日数
    @Published var consecutiveDays: Int = 0

    let roomViewModel = RoomViewModel()

    // 目標時間の時間部分（0-12時間）
    var goalHours: Int {
        get { goalMinutes / 60 }
        set { goalMinutes = newValue * 60 + goalMinutesOnly }
    }

    // 目標時間の分部分（0, 10, 20, 30, 40, 50）
    var goalMinutesOnly: Int {
        get { goalMinutes % 60 }
        set { goalMinutes = goalHours * 60 + newValue }
    }

    // 目標時間の表示用テキスト
    var goalTimeText: String {
        let hours = goalHours
        let minutes = goalMinutesOnly

        if hours > 0 && minutes > 0 {
            return "\(hours)時間\(minutes)分"
        } else if hours > 0 {
            return "\(hours)時間"
        } else {
            return "\(minutes)分"
        }
    }

    // 今日の日付を「(M月d日曜日)」形式で表示
    var todayDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "(M月d"
        let dateString = formatter.string(from: Date())

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "ja_JP")
        weekdayFormatter.dateFormat = "E"
        let weekday = weekdayFormatter.string(from: Date())

        return "\(dateString)\(weekday))"
    }

    // 連続日数の表示テキスト
    var consecutiveDaysText: String {
        return "×=\(consecutiveDays)"
    }

    init() {
        // 保存された目標を読み込む
        if let savedGoalText = UserDefaults.standard.string(forKey: "goalText") {
            self.goalText = savedGoalText
        }

        // 新形式（分単位）で保存されているかチェック
        let savedGoalMinutes = UserDefaults.standard.integer(forKey: "goalMinutes")
        if savedGoalMinutes > 0 {
            self.goalMinutes = savedGoalMinutes
        } else {
            // 旧形式（時間単位）から移行
            let savedGoalHours = UserDefaults.standard.integer(forKey: "goalHours")
            if savedGoalHours > 0 {
                self.goalMinutes = savedGoalHours * 60
            }
        }

        // 連続日数を読み込む
        self.consecutiveDays = UserDefaults.standard.integer(forKey: "consecutiveDays")
    }
}

