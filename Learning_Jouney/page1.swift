//
//  page1.swift
//  Learning_Jouney
//
//  Created by Hissah Alohali on 30/04/1447 AH.
//

import SwiftUI

struct page1: View {
    @State private var learningGoal = ""
    @State private var selectedPeriod = ""
    @State private var nextPage = false;
    var body: some View {
        NavigationStack{
            ZStack{ //for background
                Color("BG_Color").ignoresSafeArea()
                VStack {
                    ZStack {
                        Circle()
                            .padding(2)
                            .frame(width: 109, height: 109)
                            .foregroundColor(.black)
                        
                        Image("flame")
                    }
                    .glassEffect()
                    
                    
                    //
                    Text("Hello Learner")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    //                
                    Text("This app will help you learn everyday!")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    Text("I want to learn")
                        .font(.system(size: 22, weight: .regular, design: .default))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Swift", text: $learningGoal)
                    
                        .padding() 
                    Text("I want to learn it in a")
                        .font(.system(size: 22, weight: .regular, design: .default))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Button(action: {
                            selectedPeriod = "week"
                        }) {
                            Text("Week")
                                .frame(maxWidth: .infinity)
                        }.padding(2)
                            .buttonStyle(PeriodButtonStyle(isSelected: selectedPeriod == "week", width: 97, height: 48))
                        
                        
                        Button(action: {
                            selectedPeriod = "month"
                        }) {
                            Text("Month")
                                .frame(maxWidth: .infinity)
                        }.padding(2)
                            .buttonStyle(PeriodButtonStyle(isSelected: selectedPeriod == "month", width: 97, height: 48))
                        
                        Button(action: {
                            selectedPeriod = "year"
                        }) {
                            Text("Year")
                                .frame(maxWidth: .infinity)
                        }.padding(2)
                            .buttonStyle(PeriodButtonStyle(isSelected: selectedPeriod == "year", width: 97, height: 48))
                    }
                    .padding()
                    Spacer()
                    
                    Button("Start Learning") {
                        nextPage = true // Set the state to true to trigger navigation
                    }
                    .buttonStyle(StartLearningButtonStyle())
                    .padding(2)
                    
                    // Hidden NavigationLink controlled by nextPage
                    NavigationLink(destination: page2(), isActive: $nextPage) {
                        EmptyView() // Hidden view for navigation
                    }
                }
                
                
                
                
                
            }
            .padding()
            
        }
        
        
        
    }
}

#Preview {
    page1()
}
