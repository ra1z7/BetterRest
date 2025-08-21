//
//  ContentView.swift
//  BetterRest
//
//  Created by Purnaman Rai (College) on 20/08/2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker(
                        "Please select a time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("your desired amount of sleep?") {
                    Stepper(
                        "\(sleepAmount.formatted()) hours",
                        value: $sleepAmount,
                        in: 4...12,
                        step: 0.25
                    )
                }

                Section("Daily coffee intake") {
                    Picker("How many cups a day?", selection: $coffeeAmount) {
                        ForEach(0..<21) { number in
                            Text("^[\(number) cups](inflect: true)")
                        }
                    }
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
