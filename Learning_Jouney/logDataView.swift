//
//  logDataView.swift
//  Learning_Jouney
//
//  Created by Hissah Alohali on 01/05/1447 AH.
//

import Foundation
import SwiftUI

struct logDataView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        VStack {
                Button(action: {
                    // Mark today as learned; this updates stats and persists
                    viewModel.toggleLearned(for: Date())
                }) {
                    Text("Log as \nLearned")
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .frame(width: 274, height: 274)
                }
                .glassEffect(.regular.tint(Color("Orange").opacity(0.5)))
                .padding()
            
            Button(action: {
                // Mark today as freezed; this updates stats and persists
                viewModel.toggleFreezed(for: Date())
            }) {
                Text("Log as Freezeed")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 274, height: 48)
            }
            .glassEffect(.regular.tint(Color("Teal").opacity(0.5)))
            
        }
    }
}
