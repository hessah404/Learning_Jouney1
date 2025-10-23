//
//  CalendarDayView.swift
//  Learning_Jouney
//
//  Created by Hissah Alohali on 01/05/1447 AH.
//


// Views/CalendarDayView.swift
import SwiftUI

struct CalendarDayView: View {
    let day: CalendarDay
    let onLearned: () -> Void
    let onFreezed: () -> Void
    
    var body: some View {
        VStack {
            Text("\(day.dayNumber)")
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        }
        .frame(width: 44, height: 44)
        .background(dateColor)
        .clipShape(Circle())
    }
    
    private var dateColor: Color {
        if day.isLearned {
            return Color("Orange")
        } else if day.isFreezed {
            return Color("Teal")
        } else {
            return .clear
        }
    }
}
