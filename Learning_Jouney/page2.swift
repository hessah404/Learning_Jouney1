//
//  page2.swift
//  Learning_Jouney
//
//  Created by Hissah Alohali on 30/04/1447 AH.
//

import SwiftUI

struct page2: View {
    @State private var calendarSelected = false;
    @State private var personSelected = false;
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BG_Color").ignoresSafeArea()
                VStack{
                HStack(spacing: 16) {
                    Text("Activity")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        calendarSelected = true;
                    }){
                        Image(systemName: "calendar")
                    }.buttonStyle(NavigationBarButtonStyle(isSelected: calendarSelected == true))
                    
                    NavigationLink(destination: AllActivitiespage(), isActive: $calendarSelected) {
                        EmptyView() // Hidden view for navigation
                    }
                    
                    Button(action: {
                        personSelected = true;
                    }){
                        Image(systemName: "person.circle")
                    }.buttonStyle(NavigationBarButtonStyle(isSelected: personSelected == true))
                    NavigationLink(destination: learningGoalPage(), isActive: $personSelected) {
                        EmptyView() // Hidden view for navigation
                    }
                }.padding()
                Spacer()
                
                    CalendarAndStatsView()
                    Spacer()
                    logDataView()
                
                    
            }
            }
        }
    }
}

#Preview {
    page2()
}
