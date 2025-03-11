//
//  AlarmDetailView.swift
//  DigiQ
//
//  Created by Nicolas Arango on 10/03/25.
//

import SwiftUI
import Foundation

struct AlarmDetailView: View {
    @ObservedObject var alarmManager: QueueAlarmManager
    var alarm: QueueAlarm
    @State private var remainingMinutes: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var editedName: String
    @State private var editedLocation: String
    @State private var editedDate: Date
    @State private var editedTime: Date
    @Environment(\.presentationMode) var presentationMode
    
    @State private var timeRemaining: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(alarmManager: QueueAlarmManager, alarm: QueueAlarm) {
        self.alarmManager = alarmManager
        self.alarm = alarm
        
        _editedName = State(initialValue: alarm.name)
        _editedLocation = State(initialValue: alarm.location)
        _editedDate = State(initialValue: alarm.appointmentTime)
        _editedTime = State(initialValue: alarm.appointmentTime)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.85, green: 0.93, blue: 0.99)
                    .edgesIgnoringSafeArea(.all)
                
                
                    VStack(alignment: .leading, spacing: 24) {
                        // Sección de detalles
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tiempo restante: \(timeRemaining)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                            
                            Text("Creada el: \(formattedCreationDate)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                            
                            Text("Hora creación: \(formattedCreationTime)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        
                        // Sección de edición
                        VStack(alignment: .leading, spacing: 24) {
                            // Campo de nombre
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nombre:")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                TextField("Nombre", text: $editedName)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            // Campo de ubicación
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Lugar:")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                TextField("Lugar", text: $editedLocation)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            // Selector de fecha
                            DatePicker("Fecha cita", selection: $editedDate, displayedComponents: .date)
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            // Selector de hora
                            DatePicker("Hora cita", selection: $editedTime, displayedComponents: .hourAndMinute)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        Spacer()
                        
                        // Buttons
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Descartar")
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button(action: {
                                saveChanges()
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Confirmar")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.4, green: 0.75, blue: 0.9))
                                    .cornerRadius(8)
                            }
                            .disabled(editedLocation.isEmpty)
                        }
                    }
                    .padding()
                }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                },
                trailing: Text("Editar Alarma")
                    .font(.headline)
                    .foregroundColor(.black)
            )
            .onAppear(perform: updateTimeRemaining)
            .onReceive(timer) { _ in updateTimeRemaining() }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var formattedCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: alarm.creationDate)
    }
    
    private var formattedCreationTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: alarm.creationDate)
    }
    
    private func updateTimeRemaining() {
        let now = Date()
        let calendar = Calendar.current
        
        // Calculate remaining time until appointment
        let components = calendar.dateComponents([.minute, .hour, .second], from: now, to: alarm.appointmentTime)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        remainingMinutes = (hours * 60) + minutes
        remainingSeconds = (hours * 60) + minutes + seconds
        
        if remainingSeconds <= 0 {
            timeRemaining = "0:00"
        } else if hours > 0 {
            timeRemaining = String(format: "%d:%02d", hours, minutes % 60)
        } else {
            timeRemaining = String(format: "%02d:%02d", minutes, seconds % 60)
        }
    }
    
    private func combineDateAndTime() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: editedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: editedTime)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? editedDate
    }
    
    private func saveChanges() {
        let combinedDate = combineDateAndTime()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: combinedDate)
        
        let updatedAlarm = QueueAlarm(
            id: alarm.id,
            name: editedName,
            time: timeString,
            location: editedLocation,
            creationDate: alarm.creationDate,
            date: Date(),
            appointmentTime: combinedDate
        )
        
        alarmManager.updateAlarm(updatedAlarm)
    }
}
