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

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var idealSleepTime: Date {
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
            return wakeUp - prediction.actualSleep  // you can subtract a value in seconds directly from a Date
        } catch {
            print("There was a problem calculating the bedtime.")
        }
        
        return .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("When do you want to wake up?")
                            .font(.headline)

                        Spacer()

                        DatePicker(
                            "Please select a time",
                            selection: $wakeUp,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("What's your desired amount of sleep?")
                            .font(.headline)
                        Stepper(
                            "\(sleepAmount.formatted()) hours",
                            value: $sleepAmount,
                            in: 4...12,
                            step: 0.25
                        )
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Daily coffee intake")
                            .font(.headline)
                        // Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                        Stepper(
                            "^[\(coffeeAmount) cup](inflect: true)",
                            value: $coffeeAmount,
                            in: 0...20
                        )
                        //  This syntax tells SwiftUI that the word "cup" needs to be inflected to match whatever is in the coffeeAmount variable, which in this case means it will automatically be converted from "cup" to "cups" as appropriate.
                    }
                }
                
                Section {
                    VStack {
                        Text("Your Ideal Bedtime")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding()
                        
                        HStack {
                            Spacer()
                            
                            Text(idealSleepTime.formatted(date: .omitted, time: .shortened))
                                .font(.largeTitle.monospaced().bold())
                            
                            Spacer()
                        }
                        .padding()
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

#Preview {
    ContentView()
}
