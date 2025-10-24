// logDataView.swift
import SwiftUI

struct logDataView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            // "Log as Learned" button
            Button(action: {
                if !viewModel.isTodayLogged() {
                    viewModel.toggleLearned(for: Date())
                }
            }) {
                ZStack {
                    // Background layer (only this will have opacity)
                    Circle()
                        .fill(
                            viewModel.isTodayLearned()
                            ? Color("Orange")
                            : (viewModel.isTodayFreezed() ? Color("Teal") : Color.clear)
                        )
                        .glassEffect(.regular)
                        .opacity(
                            (viewModel.isTodayLearned() || viewModel.isTodayFreezed()) ? 0.1 : 0.7
                        )

                    Text(
                        viewModel.isTodayLearned() ? "Learned \nToday" :
                        viewModel.isTodayFreezed() ? "Freezed Today" : "Log as \nLearned"
                    )
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(viewModel.isTodayLearned() ? Color("Orange") : .white)
                    .multilineTextAlignment(.center)
                }
                .frame(width: 274, height: 274)
            }
            .disabled(viewModel.isTodayLogged())
            .padding()

            
            // "Log as Freezed" button
            Button(action: {
                if !viewModel.isTodayLogged() {
                    viewModel.toggleFreezed(for: Date())
                }
            }) {
                Text("Log as Freezed")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 274, height: 48)
            }
            .glassEffect(.regular.tint(Color("Teal")))
            .opacity(viewModel.isTodayFreezed() ? 0.3 : 0.7)
            .disabled(viewModel.isTodayLogged())
            
            Spacer()
            
            Text("\(viewModel.learningStats.daysFreezed) out  of \(viewModel.learningStats.freezesAvailable) freezes used")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.gray)
                
        }
        .onAppear {
            viewModel.generateCalendarDays()
        }
    }
}
