//
//  AppState.swift
//  Learning_Jouney
//
//  Created by Hissah Alohali on 02/05/1447 AH.
//

import Foundation
import SwiftUI

final class AppState: ObservableObject {
    static let shared = AppState()
    
    @AppStorage("learningGoal") var learningGoal: String = ""
    @AppStorage("learningPeriod") var learningPeriod: String = ""
    @AppStorage("lastLearnedDate") var lastLearnedDate: Double = 0
    @AppStorage("streakCount") var streakCount: Int = 0

    // MARK: - Logic
    var shouldShowSetup: Bool {
        let noGoal = learningGoal.isEmpty
        let streakExpired = hasBeenInactive()
        return noGoal || streakExpired
    }

    func hasBeenInactive() -> Bool { //when user is inactive for 32+ hours
        guard lastLearnedDate > 0 else { return false }
        let hoursSince = (Date().timeIntervalSince1970 - lastLearnedDate) / 3600
        return hoursSince > 32
    }

    // MARK: - Reset Conditions
    func resetProgress() {
        streakCount = 0
        lastLearnedDate = 0
    }

    // when user edits goal in EditGoalPage
    func updateGoal(from newGoal: String, period newPeriod: String) {
        // Reset streak only when editing through settings
        resetProgress()
        learningGoal = newGoal
        learningPeriod = newPeriod
    }

    // Called when user sets goal first time in Page1
    func setInitialGoal(_ goal: String, period: String) {
        learningGoal = goal
        learningPeriod = period
        streakCount = 0
        lastLearnedDate = Date().timeIntervalSince1970
    }
}
