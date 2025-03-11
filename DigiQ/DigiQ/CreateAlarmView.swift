import SwiftUI

struct CreateAlarmView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var alarmManager: QueueAlarmManager
    
    @State private var alarmName = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var location = ""
    @State private var showTimePicker = false
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.85, green: 0.93, blue: 0.99)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Alarm Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre:")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        TextField("Ingrese nombre de la alarma", text: $alarmName)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Time section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hora:")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Button(action: {
                            showTimePicker.toggle()
                        }) {
                            HStack {
                                Spacer()
                                Text(formattedTime)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(white: 0.9, opacity: 0.7))
                                    .cornerRadius(8)
                            }
                        }
                        
                        if showTimePicker {
                            VStack {
                                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .frame(maxHeight: 150)
                                    .clipped()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(12)
                            }
                            .transition(.opacity)
                        }
                    }
                    
                    // Date section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fecha:")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Button(action: {
                            showDatePicker.toggle()
                        }) {
                            HStack {
                                Spacer()
                                Text(formattedDate)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(white: 0.9, opacity: 0.7))
                                    .cornerRadius(8)
                            }
                        }
                        
                        if showDatePicker {
                            VStack {
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .frame(maxHeight: 150)
                                    .clipped()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(12)
                            }
                            .transition(.opacity)
                        }
                    }
                                       
                    // Location section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lugar:")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        TextField("Ingrese ubicación", text: $location)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
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
                            saveAlarm()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Confirmar")
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.4, green: 0.75, blue: 0.9))
                                .cornerRadius(8)
                        }
                        .disabled(location.isEmpty)
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
                trailing: Text("Crear Alarma")
                    .font(.headline)
                    .foregroundColor(.black)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: selectedTime)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func saveAlarm() {
        // Use the AlarmManager to add the alarm with the custom name
        let name = alarmName.isEmpty ? "Alarma" : alarmName
        
        alarmManager.addAlarm(
            name: name,
            location: location.isEmpty ? "Sin especificar" : location,
            creationDate: Date(),
            date: selectedDate,
            time: selectedTime
        )
    }
}
