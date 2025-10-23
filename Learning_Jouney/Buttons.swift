//
//  Buttons.swift
//  Learning_Jouney
//
//  Created by Hissah Alohali on 30/04/1447 AH.
//

import Foundation
import SwiftUI

struct PeriodButtonStyle: ButtonStyle {
    var isSelected: Bool
    var width: CGFloat
    var height: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .glassEffect()
            .frame(width: width, height: height)
            .background(isSelected ? Color("Orange") : Color.black)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24)) // Adjusted corner radius
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct StartLearningButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(width: 182, height: 48)
            .glassEffect()
            .background(Color("Orange")) // Always orange
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
}

struct NavigationBarButtonStyle: ButtonStyle{
    var isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(width: 44, height: 44)
            .glassEffect()
            .background(isSelected ? Color("Orange") : Color.black)
            .foregroundColor(.white)
            //.clipShape(RoundedRectangle(cornerRadius: 24))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
}

