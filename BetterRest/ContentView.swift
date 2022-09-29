//
//  ContentView.swift
//  BetterRest
//
//  Created by Jesus Calleja on 20/9/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var bedTime = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    private static let cups = [Int](0..<21)
    
    private static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(.black)
        UINavigationBar.appearance().backgroundColor = UIColor(.black)
        UIStepper.appearance().setDecrementImage(UIImage(systemName: "minus"), for: .normal)
                UIStepper.appearance().setIncrementImage(UIImage(systemName: "plus"), for: .normal)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("When do you want to wake up?").font(.system(size: 18, weight: .bold, design: .rounded))) {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .onChange(of: wakeUp) { val in
                                self.calculateBedtime()
                            }
                            .labelsHidden()
                            .colorInvert()
                            .colorMultiply(Color.white)
                        
                    }
                    .listRowBackground(Color.clear)
                    .foregroundColor(.white)
                    
                    Section(header: Text("Desire amount of sleep").font(.system(size: 18, weight: .bold, design: .rounded))) {
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                            .onChange(of: sleepAmount) { val in
                                self.calculateBedtime()
                            }
                    }
                    .listRowBackground(Color.clear)
                    .foregroundColor(.white)
                    
                    Section(header: Text("Daily coffee intake").font(.system(size: 18, weight: .bold, design: .rounded))) {
                        Picker("Number of cups", selection: $coffeeAmount) {
                            ForEach(0 ..< 21) { index in
                                Text("\(index)")
                                    .foregroundColor(.white)
                                    .tag(index)
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: coffeeAmount) { val in
                            self.calculateBedtime()
                        }
                    }
                    .listRowBackground(Color.clear)
                   .foregroundColor(.white)
                    Text("Ideal bedtime: \(self.bedTime)").font(.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .onAppear(perform: self.calculateBedtime)
                        .foregroundColor(.white)
                        .listRowBackground(Color.clear)
                }
                .background(.black)
                .onAppear {
                  UITableView.appearance().backgroundColor = .clear
                }
                .onDisappear {
                  UITableView.appearance().backgroundColor = .systemGroupedBackground
                }
                Text("⏰ 💤 ☕").font(.largeTitle)
            }

            .navigationTitle("BetterRest")
            .accentColor(.white)
            .background(Color.black)
            .alert(self.alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(self.alertMessage)
            }
        }
    }
    
    private func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            self.bedTime = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            self.alertTitle = "Error"
            self.alertMessage = "Sorry, there was a problem calculating yoour bedtime."
            self.showingAlert = true
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
