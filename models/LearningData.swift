//
//  LearningData.swift
//  Learning_Jouney
//
//  Created by Hissah Alohali on 01/05/1447 AH.
//


// Models/LearningData.swift
import Foundation

struct LearningData: Codable {
    var learnedDates: [String: Bool]
    var freezedDates: [String: Bool]
    var lastStats: LearningStats
}