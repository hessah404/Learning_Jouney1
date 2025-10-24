import SwiftUI

struct CalendarAndStatsView: View {
    @StateObject private var viewModel = CalendarViewModel()
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    @AppStorage("learningGoal") private var learningGoal: String = ""
    
    var body: some View {
        ZStack {
            // Background rounded rectangle with glass effect
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(.clear)
                .frame(width: 365, height: 254)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
            
            VStack(spacing: 16) {
                // Header with month and navigation
                HStack {
                    Button(action: { viewModel.showMonthPicker.toggle() }) {
                        HStack(spacing: 4) {
                            Text(viewModel.monthYearString())
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("Orange"))
                                .font(.system(size: 26, weight: .semibold))
                        }
                    }
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: { viewModel.navigateToPreviousWeek() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("Orange"))
                                .font(.system(size: 26, weight: .semibold))
                        }
                        Button(action: { viewModel.navigateToNextWeek() }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("Orange"))
                                .font(.system(size: 26, weight: .semibold))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Days of week headers
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)

                // Calendar days grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                    ForEach(viewModel.calendarDays.prefix(7)) { day in
                        CalendarDayView(day: day) {
                            viewModel.toggleLearned(for: day.date)
                        } onFreezed: {
                            viewModel.toggleFreezed(for: day.date)
                        }
                        .frame(height: 32)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 30)
                
                // Separator line
                separatorLine()
                
                // Learning goal
                Text(learningGoal)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .lineLimit(1)

                // Stats - Keep the original layout
                HStack(spacing: 12) {
                    // Learned
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color("Orange"))
                            .font(.system(size: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(viewModel.learningStats.daysLearned)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(viewModel.learningStats.daysLearned == 1 ? "Day" : "Days") Learned")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(width: 160, height: 60)
                    .background(Color("Orange").opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 34))

                    // Freezed
                    HStack(spacing: 8) {
                        Image(systemName: "cube.fill")
                            .foregroundColor(Color("Teal"))
                            .font(.system(size: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(viewModel.learningStats.daysFreezed)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(viewModel.learningStats.daysFreezed == 1 ? "Day" : "Days") Freezed")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(width: 160, height: 60)
                    .background(Color("Teal").opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 34))
                }
                .padding(.horizontal, 20)
            }
            .frame(width: 365, height: 254)
        }
        .onAppear {
            viewModel.generateCalendarDays()
        }
    }
    
    // MARK: - Local helpers
    @ViewBuilder
    private func separatorLine() -> some View {
        Divider()
            .background(Color.white.opacity(0.2))
            .padding(.horizontal, 20)
    }
}
