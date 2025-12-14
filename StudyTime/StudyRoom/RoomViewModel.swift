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
    
    @Published var studyMinutes: Int = 25
    @Published var breakMinutes: Int = 5
    
    private var timer: Timer?
    
    func startTimer() {
        remainingTime = isStudyMode ? studyMinutes * 60 : breakMinutes * 60
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
}
