import SwiftUI

struct CalendarDayView: View {
    let day: CalendarDay
    let onLearned: () -> Void
    let onFreezed: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {

            Text("\(calendar.component(.day, from: day.date))")
                .font(.system(size: 24, weight: .medium, design: .default))
                .foregroundColor(textColor)
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .clipShape(Circle())
    }
    
    private var textColor: Color {
        if day.isLearned || day.isFreezed {
            return .white
        } else if day.isToday {
            return .white
        } else {
            return day.isCurrentMonth ? .white : .gray
        }
    }
    
    private var backgroundColor: Color {
        if day.isLearned {
            return Color("Orange").opacity(opacity)
        } else if day.isFreezed {
            return Color("Teal").opacity(opacity)
        } else {
            return Color.clear
        }
    }
    
    private var opacity: Double {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDateInToday(day.date) {
            return 1.0 // Full opacity for current day
        } else if day.date < today {
            return 0.3 // Lower opacity for past days
        } else {
            return 0.7 // Default opacity for future days
        }
    }
}
