// ViewModels/CalendarViewModel.swift
import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date() // Set to current date
    @Published var calendarDays: [CalendarDay] = []
    @Published var learningStats: LearningStats = LearningStats(daysLearned: 0, daysFreezed: 0)
    @Published var showMonthPicker: Bool = false
    @Published var currentWeekOffset: Int = 0 // Track which week we're viewing
    
    private let calendar = Calendar.current
    private let userDefaults = UserDefaults.standard
    private let learningDataKey = "learningData"
    
    init() {
        // Ensure the initial week displayed contains "today"
        currentWeekOffset = weekOffsetFor(date: Date(), within: currentMonth)
        loadLearningData()
        generateCalendarDays()
    }
    
    func generateCalendarDays() {
        calendarDays.removeAll()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else { return }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysToAdd = firstWeekday - 1
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToAdd, to: monthStart) else { return }
        
        // Calculate the start date for the current week view
        let weekStartDate = calendar.date(byAdding: .day, value: currentWeekOffset * 7, to: startDate) ?? startDate
        
        // Only show 7 days (one week)
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
            
            calendarDays.append(calendarDay)
        }
        
        updateLearningStats()
    }
    
    // MARK: - Helper Methods
    
    private func weekOffsetFor(date: Date, within month: Date) -> Int {
        // Compute the same startDate baseline used by generateCalendarDays()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return 0 }
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysToAdd = firstWeekday - 1
        guard let startDate = calendar.date(byAdding: .day, value: -daysToAdd, to: monthStart) else { return 0 }
        
        // Number of days from the baseline to the target date
        let daysDifference = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        // Integer division gives the week row index
        return max(0, daysDifference / 7)
    }
    
    private func getDateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func getLearnedStatus(for dateKey: String) -> Bool {
        if let savedData = loadLearningDataFromStorage() {
            return savedData.learnedDates[dateKey] ?? false
        }
        // Default learned dates for testing
        let learnedDates = ["2025-10-20", "2025-10-21", "2025-10-22"]
        return learnedDates.contains(dateKey)
    }
    
    private func getFreezedStatus(for dateKey: String) -> Bool {
        if let savedData = loadLearningDataFromStorage() {
            return savedData.freezedDates[dateKey] ?? false
        }
        // Default freezed dates for testing
        let freezedDates = ["2025-10-23"]
        return freezedDates.contains(dateKey)
    }
    
    private func loadLearningDataFromStorage() -> LearningData? {
        if let data = userDefaults.data(forKey: learningDataKey) {
            let decoder = JSONDecoder()
            if let learningData = try? decoder.decode(LearningData.self, from: data) {
                return learningData
            }
        }
        return nil
    }
    
    private func loadLearningData() {
        if let savedData = loadLearningDataFromStorage() {
            self.learningStats = savedData.lastStats
        } else {
            self.learningStats = LearningStats(daysLearned: 0, daysFreezed: 0)
        }
    }
    
    private func saveLearningData() {
        var learnedDates: [String: Bool] = [:]
        var freezedDates: [String: Bool] = [:]
        
        for day in calendarDays {
            let dateKey = getDateKey(from: day.date)
            if day.isLearned {
                learnedDates[dateKey] = true
            }
            if day.isFreezed {
                freezedDates[dateKey] = true
            }
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
    
    func updateLearningStats() {
        let learnedCount = calendarDays.filter { $0.isLearned }.count
        let freezedCount = calendarDays.filter { $0.isFreezed }.count
        
        learningStats = LearningStats(daysLearned: learnedCount, daysFreezed: freezedCount)
    }
    
    // MARK: - User Actions
    
    func toggleLearned(for date: Date) {
        let dateKey = getDateKey(from: date)
        
        if let index = calendarDays.firstIndex(where: { getDateKey(from: $0.date) == dateKey }) {
            calendarDays[index].isLearned.toggle()
            
            if calendarDays[index].isLearned {
                calendarDays[index].isFreezed = false
            }
            
            updateLearningStats()
            saveLearningData()
        }
    }
    
    func toggleFreezed(for date: Date) {
        let dateKey = getDateKey(from: date)
        
        if let index = calendarDays.firstIndex(where: { getDateKey(from: $0.date) == dateKey }) {
            calendarDays[index].isFreezed.toggle()
            
            if calendarDays[index].isFreezed {
                calendarDays[index].isLearned = false
            }
            
            updateLearningStats()
            saveLearningData()
        }
    }
    
    // MARK: - Navigation
    
    func monthYearString() -> String {
        // Get the first day of the currently displayed week to determine the actual month/year
        if let firstDayOfWeek = calendarDays.first?.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: firstDayOfWeek)
        }
        
        // Fallback to currentMonth if no days are available
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    func navigateToPreviousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
            // Recalculate offset so initial week of that month contains the same relative “today” if in that month,
            // otherwise default to first week containing the 1st of the month.
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
        
        // Update currentMonth if we've navigated to a different month
        updateCurrentMonthIfNeeded()
    }

    func navigateToNextWeek() {
        currentWeekOffset += 1
        generateCalendarDays()
        
        // Update currentMonth if we've navigated to a different month
        updateCurrentMonthIfNeeded()
    }
    
    private func updateCurrentMonthIfNeeded() {
        // Check if the first day of the displayed week is in a different month than currentMonth
        if let firstDayOfWeek = calendarDays.first?.date,
           !calendar.isDate(firstDayOfWeek, equalTo: currentMonth, toGranularity: .month) {
            
            // Update currentMonth to the month of the first day of the displayed week
            if let newMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: firstDayOfWeek)) {
                currentMonth = newMonth
                
                // Recalculate week offset for the new month
                recalculateWeekOffset(for: firstDayOfWeek)
            }
        }
    }
    
    private func recalculateWeekOffset(for date: Date) {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { return }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysToAdd = firstWeekday - 1
        
        guard let calendarStartDate = calendar.date(byAdding: .day, value: -daysToAdd, to: monthStart) else { return }
        
        // Calculate how many weeks from the start of the month this date is
        let daysDifference = calendar.dateComponents([.day], from: calendarStartDate, to: date).day ?? 0
        currentWeekOffset = daysDifference / 7
    }
}

