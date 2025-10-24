import SwiftUI

struct UpdateGoalPage: View {
    @AppStorage("learningGoal") public var learningGoal: String = ""
    @AppStorage("selectedPeriod") public var selectedPeriod: String = ""
    @State private var done = false
    @State private var isTextFieldActive = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Learning Goal")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                    
                    // Check mark only appears when text field is active
                    if isTextFieldActive {
                        Button(action: {
                            done = true
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        
                        NavigationLink(destination: page2(), isActive: $done) {
                            EmptyView()
                        }
                    }
                }
                .padding(.horizontal)

                // "I want to learn" section
                Text("I want to learn")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Text field
                TextField("Swift", text: $learningGoal, onEditingChanged: { editing in
                    isTextFieldActive = editing
                })
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.horizontal)
                
                // "I want to learn it in a" section
                Text("I want to learn it in a")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Period selection buttons
                HStack(spacing: 12) {
                    Button(action: {
                        selectedPeriod = "Week"
                    }) {
                        Text("Week")
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .buttonStyle(PeriodButtonStyle(
                        isSelected: selectedPeriod == "Week",
                        width: 97,
                        height: 48
                    ))
                    
                    Button(action: {
                        selectedPeriod = "Month"
                    }) {
                        Text("Month")
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .buttonStyle(PeriodButtonStyle(
                        isSelected: selectedPeriod == "Month",
                        width: 97,
                        height: 48
                    ))
                    
                    Button(action: {
                        selectedPeriod = "Year"
                    }) {
                        Text("Year")
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .buttonStyle(PeriodButtonStyle(
                        isSelected: selectedPeriod == "Year",
                        width: 97,
                        height: 48
                    ))
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
        }
    }
}
