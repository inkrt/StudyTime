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
        VStack{
            Text(viewModel.isStudyMode ? "勉強時間" : "休憩時間")
            
            Text(viewModel.timeString)
            
            HStack{
                Button(viewModel.isRunning ? "停止" : "開始") {
                    if viewModel.isRunning {
                        viewModel.stopTimer()
                    } else {
                        viewModel.startTimer()
                    }
                    
                }
                
                Button{
                        viewModel.resetTimer()
                    } label: {
                        Text("リセット")
                    }
                
                
            }
            VStack{
                HStack{
                    Text("勉強時間:")
                    Stepper("\(viewModel.studyMinutes)分", value: $viewModel.studyMinutes, in: 1...60)
                }
                HStack{
                    Text("休憩時間:")
                    Stepper("\(viewModel.breakMinutes)分", value: $viewModel.breakMinutes, in: 1...30)
                }
            }
        }
        
       
    }
}

#Preview {
    StudyRoomView()
        .environmentObject(RoomViewModel())
}
