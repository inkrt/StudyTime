//
//  HomeViewModel.swift
//  StudyTime
//
//  Created by 舛水葵 on 2026/01/11.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var goalText: String = "毎日勉強する" {
        didSet {
            UserDefaults.standard.set(goalText, forKey: "goalText")
        }
    }
    @Published var goalHours: Int = 2 {
        didSet {
            UserDefaults.standard.set(goalHours, forKey: "goalHours")
        }
    }
    @Published var showGoalSettings: Bool = false

    let roomViewModel = RoomViewModel()

    init() {
        // 保存された目標を読み込む
        if let savedGoalText = UserDefaults.standard.string(forKey: "goalText") {
            self.goalText = savedGoalText
        }
        let savedGoalHours = UserDefaults.standard.integer(forKey: "goalHours")
        if savedGoalHours > 0 {
            self.goalHours = savedGoalHours
        }
    }
}

