//
//  HomeView.swift
//  StudyTime
//
//  Created by 舛水葵 on 2025/12/14.
//

import SwiftUI

struct HomeView: View {
  
    
    var body: some View {
        NavigationView{
        VStack{
            Image("tameshi")
                .resizable()
                .frame(width: 400, height: 400)
            Text("今日の勉強時間")
            Text("目標")
            
                NavigationLink{
                    StudyRoomView()
                    
                } label: {
                    Text("勉強をする")
//                    その後にどの友達とやる？みたいなのを追加したい
                }
            }
        }
    }
}


#Preview {
    HomeView()
     
}
