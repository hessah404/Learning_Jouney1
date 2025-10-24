import Foundation

struct LearningStats: Codable {
    var daysLearned: Int
    var daysFreezed: Int
    var currentStreak: Int
    var freezesUsed: Int
    var freezesAvailable: Int
    
    init(
        daysLearned: Int = 0,
        daysFreezed: Int = 0,
        currentStreak: Int = 0,
        freezesUsed: Int = 0,
        freezesAvailable: Int = 2
    ) {
        self.daysLearned = daysLearned
        self.daysFreezed = daysFreezed
        self.currentStreak = currentStreak
        self.freezesUsed = freezesUsed
        
        // Determine period from AppState singleton
        let period = AppState.shared.learningPeriod.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Compute the base allowance by period with a default
        let baseAllowance: Int
        switch period {
        case "Week":
            baseAllowance = 2
        case "Month":
            baseAllowance = 8
        case "Year":
            baseAllowance = 96
        default:
            // Fallback if period hasn’t been set yet or is unexpected
            baseAllowance = freezesAvailable
        }
        
        // Ensure non-negative available freezes
        let computed = baseAllowance - freezesUsed
        self.freezesAvailable = computed
    }
}
