//
//  ContentView.swift
//  BetterRest
//
//  Created by Purnaman Rai (College) on 20/08/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker(
                        "Please select a time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }

                Section {
                    Text("What's your desired amount of sleep?")
                        .font(.headline)
                    Stepper(
                        "\(sleepAmount.formatted()) hours",
                        value: $sleepAmount,
                        in: 4...12,
                        step: 0.25
                    )
                }

                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper(
                        "\(coffeeAmount) cup(s)",
                        value: $coffeeAmount,
                        in: 1...20
                    )
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
        }
    }

    func calculateBedtime() {

    }
}

#Preview {
    ContentView()
}
