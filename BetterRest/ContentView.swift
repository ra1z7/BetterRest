//
//  ContentView.swift
//  BetterRest
//
//  Created by Purnaman Rai (College) on 20/08/2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

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
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUp
            )
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minuteInSeconds = (components.minute ?? 0) * 60

            let prediction = try model.prediction(
                wake: Double(hourInSeconds + minuteInSeconds),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            // 'prediction.actualSleep' will be some number in seconds
            let sleepTime = wakeUp - prediction.actualSleep  // you can subtract a value in seconds directly from a Date
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error!"
            alertMessage = "There was an error calculating your sleep time"
        }

        showingAlert = true
    }
}

#Preview {
    ContentView()
}
