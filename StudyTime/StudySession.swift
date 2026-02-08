//
//  StudySession.swift
//  StudyTime
//
//  Created by Claude on 2026/01/25.
//

import Foundation
import SwiftData

@Model
final class StudySession {
    var id: UUID
    var date: Date
    var subject: String
    var durationSeconds: Int
    var startTime: Date
    var endTime: Date

    init(subject: String, durationSeconds: Int, startTime: Date, endTime: Date) {
        self.id = UUID()
        self.date = startTime
        self.subject = subject
        self.durationSeconds = durationSeconds
        self.startTime = startTime
        self.endTime = endTime
    }
}
