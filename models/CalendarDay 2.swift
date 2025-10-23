//
//  CalendarDay 2.swift
//  Learning_Jouney
//
//  Created by Hissah Alohali on 01/05/1447 AH.
//


// Models/CalendarDay.swift
import Foundation

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    var isLearned: Bool
    var isFreezed: Bool

    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
}
