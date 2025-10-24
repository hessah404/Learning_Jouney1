import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var calendarDays: [CalendarDay] = []
    @Published var learningStats: LearningStats = LearningStats(daysLearned: 0, daysFreezed: 0, currentStreak: 0, freezesUsed: 0, freezesAvailable: 2)
    @Published var showMonthPicker: Bool = false
    @Published var currentWeekOffset: Int = 0
    
    private let calendar = Calendar.current
    private let userDefaults = UserDefaults.standard
    private let learningDataKey = "learningData"
    
    private var todayKey: String {
        getDateKey(from: Date())
    }
    
    init() {
        currentWeekOffset = weekOffsetFor(date: Date(), within: currentMonth)
        loadLearningData()
        generateCalendarDays()
        checkStreakValidity()
    }
    
    // MARK: - Calendar Generation
    func generateCalendarDays() {
        var tempDays: [CalendarDay] = []
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else { return }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysToAdd = firstWeekday - 1
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToAdd, to: monthStart) else { return }
        
        let weekStartDate = calendar.date(byAdding: .day, value: currentWeekOffset * 7, to: startDate) ?? startDate
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDate) else { continue }
            
            let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
            let isToday = calendar.isDateInToday(date)
            
            let dateKey = getDateKey(from: date)
            let isLearned = getLearnedStatus(for: dateKey)
            let isFreezed = getFreezedStatus(for: dateKey)
            
            let calendarDay = CalendarDay(
                date: date,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                isLearned: isLearned,
                isFreezed: isFreezed
            )
            
            tempDays.append(calendarDay)
        }
        
        calendarDays = tempDays
    }
    
    // MARK: - Streak Management
    private func checkStreakValidity() {
        let today = Date()
        
        // Check if streak is broken (more than 32 hours without logging)
        if let lastLearnedDate = getLastLearnedDate() {
            let hoursSinceLastLearn = calendar.dateComponents([.hour], from: lastLearnedDate, to: today).hour ?? 0
            
            if hoursSinceLastLearn > 32 {
                // Check if freeze was used for the gap
                if !wasFreezeUsedDuringGap(from: lastLearnedDate, to: today) {
                    learningStats.currentStreak = 0
                    saveLearningData()
                }
            }
        }
    }
    
    private func getLastLearnedDate() -> Date? {
        guard let savedData = loadLearningDataFromStorage() else { return nil }
        
        let learnedDates = savedData.learnedDates.compactMap { key, value -> Date? in
            guard value else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: key)
        }.sorted(by: >)
        
        return learnedDates.first
    }
    
    private func wasFreezeUsedDuringGap(from startDate: Date, to endDate: Date) -> Bool {
        guard let savedData = loadLearningDataFromStorage() else { return false }
        
        var currentDate = calendar.startOfDay(for: startDate)
        let endDate = calendar.startOfDay(for: endDate)
        
        while currentDate < endDate {
            let dateKey = getDateKey(from: currentDate)
            if savedData.freezedDates[dateKey] == true {
                return true
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return false
    }
    
    private func updateStreak() {
        guard let savedData = loadLearningDataFromStorage() else { return }
        
        var currentStreak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // Calculate current streak
        while true {
            let dateKey = getDateKey(from: currentDate)
            let isLearned = savedData.learnedDates[dateKey] == true
            let isFreezed = savedData.freezedDates[dateKey] == true
            
            if isLearned || isFreezed {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        learningStats.currentStreak = currentStreak
    }
    
    // MARK: - User Actions
    func toggleLearned(for date: Date) {
        let dateKey = getDateKey(from: date)
        
        // Only allow logging for today
        guard calendar.isDateInToday(date) else { return }
        
        if let index = calendarDays.firstIndex(where: { getDateKey(from: $0.date) == dateKey }) {
            let newLearnedState = !calendarDays[index].isLearned
            
            calendarDays[index].isLearned = newLearnedState
            if newLearnedState {
                calendarDays[index].isFreezed = false
                
                // Update stats
                learningStats.daysLearned += 1
                updateStreak()
                saveLearningData()
            }
        }
    }
    
    func toggleFreezed(for date: Date) {
        let dateKey = getDateKey(from: date)
        
        // Only allow freezing for today
        guard calendar.isDateInToday(date) else { return }
        
        // Check freeze limit
        guard learningStats.freezesUsed < learningStats.freezesAvailable else {
            return
        }
        
        if let index = calendarDays.firstIndex(where: { getDateKey(from: $0.date) == dateKey }) {
            let newFreezedState = !calendarDays[index].isFreezed
            
            calendarDays[index].isFreezed = newFreezedState
            if newFreezedState {
                calendarDays[index].isLearned = false
                
                // Update stats
                learningStats.daysFreezed += 1
                learningStats.freezesUsed += 1
                updateStreak()
                saveLearningData()
            }
        }
    }
    
    // MARK: - Query Helpers for Today
    func isTodayLearned() -> Bool {
        if let today = calendarDays.first(where: { calendar.isDateInToday($0.date) }) {
            return today.isLearned
        }
        // Fallback to persisted value if today isn't in current week array yet
        return getLearnedStatus(for: todayKey)
    }
    
    func isTodayFreezed() -> Bool {
        if let today = calendarDays.first(where: { calendar.isDateInToday($0.date) }) {
            return today.isFreezed
        }
        return getFreezedStatus(for: todayKey)
    }
    
    func isTodayLogged() -> Bool {
        isTodayLearned() || isTodayFreezed()
    }
    
    // MARK: - Helper Methods
    private func weekOffsetFor(date: Date, within month: Date) -> Int {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return 0 }
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysToAdd = firstWeekday - 1
        guard let startDate = calendar.date(byAdding: .day, value: -daysToAdd, to: monthStart) else { return 0 }
        
        let daysDifference = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        return max(0, daysDifference / 7)
    }
    
    func getDateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getLearnedStatus(for dateKey: String) -> Bool {
        if let savedData = loadLearningDataFromStorage() {
            return savedData.learnedDates[dateKey] ?? false
        }
        return false
    }
    
    func getFreezedStatus(for dateKey: String) -> Bool {
        if let savedData = loadLearningDataFromStorage() {
            return savedData.freezedDates[dateKey] ?? false
        }
        return false
    }
    
    // MARK: - Data Persistence
    private func loadLearningDataFromStorage() -> LearningData? {
        if let data = userDefaults.data(forKey: learningDataKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(LearningData.self, from: data)
        }
        return nil
    }
    
    private func loadLearningData() {
        if let savedData = loadLearningDataFromStorage() {
            self.learningStats = savedData.lastStats
        }
    }
    
    private func saveLearningData() {
        var learnedDates: [String: Bool] = [:]
        var freezedDates: [String: Bool] = [:]
        
        if let existingData = loadLearningDataFromStorage() {
            learnedDates = existingData.learnedDates
            freezedDates = existingData.freezedDates
        }
        
        for day in calendarDays {
            let dateKey = getDateKey(from: day.date)
            learnedDates[dateKey] = day.isLearned
            freezedDates[dateKey] = day.isFreezed
        }
        
        let learningData = LearningData(
            learnedDates: learnedDates,
            freezedDates: freezedDates,
            lastStats: learningStats
        )
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(learningData) {
            userDefaults.set(encoded, forKey: learningDataKey)
        }
    }
    
    // MARK: - Navigation
    func monthYearString() -> String {
        if let firstDayOfWeek = calendarDays.first?.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: firstDayOfWeek)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    func navigateToPreviousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
            currentWeekOffset = weekOffsetFor(date: newDate, within: newDate)
            generateCalendarDays()
        }
    }
    
    func navigateToNextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
            currentWeekOffset = weekOffsetFor(date: newDate, within: newDate)
            generateCalendarDays()
        }
    }
    
    func navigateToPreviousWeek() {
        currentWeekOffset -= 1
        generateCalendarDays()
        updateCurrentMonth()
    }

    func navigateToNextWeek() {
        currentWeekOffset += 1
        generateCalendarDays()
        updateCurrentMonth()
    }
    
    private func updateCurrentMonth() {
        if let firstDayOfWeek = calendarDays.first?.date,
           !calendar.isDate(firstDayOfWeek, equalTo: currentMonth, toGranularity: .month) {
            if let newMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: firstDayOfWeek)) {
                currentMonth = newMonth
                recalculateWeekOffset(for: firstDayOfWeek)
            }
        }
    }
    
    private func recalculateWeekOffset(for date: Date) {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { return }
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysToAdd = firstWeekday - 1
        guard let calendarStartDate = calendar.date(byAdding: .day, value: -daysToAdd, to: monthStart) else { return }
        let daysDifference = calendar.dateComponents([.day], from: calendarStartDate, to: date).day ?? 0
        currentWeekOffset = daysDifference / 7
    }
}
