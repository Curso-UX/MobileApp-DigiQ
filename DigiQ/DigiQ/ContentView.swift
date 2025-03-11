import SwiftUI
import UserNotifications

struct QueueAlarm: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var time: String
    var location: String
    var creationDate: Date
    var date: Date
    var appointmentTime: Date
    
    static func == (lhs: QueueAlarm, rhs: QueueAlarm) -> Bool {
        return lhs.id == rhs.id
    }
}

class QueueAlarmManager: ObservableObject {
    @Published var alarms: [QueueAlarm]
    
    init(alarms: [QueueAlarm] = []) {
        self.alarms = alarms
    }
    
    func addAlarm(name: String, location: String, creationDate: Date, date: Date, time: Date) {
        // Combine date and time into a single Date object
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        guard let appointmentTime = calendar.date(from: combinedComponents) else {
            print("Error creating date from components")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: time)
        
        let newAlarm = QueueAlarm(
            name: name,
            time: timeString,
            location: location,
            creationDate: Date(),
            date: date,
            appointmentTime: appointmentTime
        )
        
        alarms.append(newAlarm)
        scheduleNotification(for: newAlarm)
    }
    
    func updateAlarm(_ updatedAlarm: QueueAlarm) {
        if let index = alarms.firstIndex(where: { $0.id == updatedAlarm.id }) {
            // Cancelar notificaciones antiguas
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [updatedAlarm.id.uuidString])
            
            // Actualizar alarma
            alarms[index] = updatedAlarm
            
            // Programar nuevas notificaciones
            scheduleNotification(for: updatedAlarm)
        }
    }
    
    private func scheduleNotification(for alarm: QueueAlarm) {
        let notificationTimes = [0, 5, 10, 15, 30] // Minutos antes de la cita
        let center = UNUserNotificationCenter.current()
        
        for minutesBefore in notificationTimes {
            let notificationTime = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: alarm.appointmentTime) ?? alarm.appointmentTime
            
            if notificationTime < Date() {
                print("No se programó la notificación de \(minutesBefore) minutos porque el tiempo ya pasó.")
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Tu cita en \(alarm.location) está próxima"
            content.body = "Faltan \(minutesBefore) minutos para tu cita."
            content.sound = UNNotificationSound.default
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(alarm.id.uuidString)_\(minutesBefore)", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error al agregar notificación: \(error)")
                } else {
                    print("Notificación programada para \(minutesBefore) minutos antes de la cita")
                }
            }
        }
    }

    
    func removeAlarm(with id: UUID) {
        alarms.removeAll { $0.id == id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        print("Notificación eliminada para \(id.uuidString)")
    }
}

struct ContentView: View {
    @StateObject private var alarmManager = QueueAlarmManager(alarms: [
        QueueAlarm(
            name: "Alarma 1",
            time: "9:41 AM",
            location: "Bancolombia",
            creationDate: Date(),
            date: Date(),
            appointmentTime: Date().addingTimeInterval(1945)
        ),
        QueueAlarm(
            name: "Alarma 2",
            time: "1:17 PM",
            location: "Hospital San José",
            creationDate: Date(),
            date: Date(),
            appointmentTime: Date().addingTimeInterval(4637)
        )
    ])
    @State private var showingCreateAlarm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.85, green: 0.93, blue: 0.99)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Text("Tus Alarmas")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                    
                    if alarmManager.alarms.isEmpty {
                        VStack {
                            Spacer()
                            Text("No tienes alarmas programadas")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 32) { // Increased spacing between cards
                                ForEach(alarmManager.alarms) { alarm in
                                    QueueCard(alarm: alarm,
                                              alarmManager: alarmManager,
                                              onDelete: {
                                        alarmManager.removeAlarm(with: alarm.id)
                                    })
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 24)
                            .padding(.bottom, 24)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingCreateAlarm = true
                    }) {
                        Text("Crear Alarma")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color(red: 0.4, green: 0.75, blue: 0.9))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.black)
                        Text("Hola,")
                            .foregroundColor(.black)
                        Text("Juan Ramírez")
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "arrow.right.square")
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showingCreateAlarm) {
                CreateAlarmView(alarmManager: alarmManager)
            }
        }
        .onAppear {
            requestNotificationPermissions()
        }
    }
    
    func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if let error = error {
                        print("Error solicitando permisos: \(error)")
                    }
                }
            } else if settings.authorizationStatus == .denied {
                print("Las notificaciones están deshabilitadas. Pide al usuario que las active en Configuración.")
            }
        }
    }
}

struct QueueCard: View {
    var alarm: QueueAlarm
    var alarmManager: QueueAlarmManager
    var onDelete: () -> Void
    
    @State private var timeRemaining: String = ""
    @State private var remainingMinutes: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var showingDetailAlarm = false // Variable para controlar la hoja
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Button(action: {
            showingDetailAlarm = true // Activa la hoja
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(alarm.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(timeRemaining)
                            .font(.system(size: 48, weight: .medium))
                        
                        Spacer()
                        
                        Button(action: onDelete) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Eliminar")
                            }
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(red: 0.4, green: 0.75, blue: 0.9))
                        Text(alarm.location)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
        }
        .buttonStyle(PlainButtonStyle()) // Evita el estilo predeterminado del botón
        .frame(height: 120)
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
        .sheet(isPresented: $showingDetailAlarm) {
            // Pasa los parámetros correctos a AlarmDetailView
            AlarmDetailView(alarmManager: alarmManager, alarm: alarm)
        }
    }
    
    private func updateTimeRemaining() {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: alarm.appointmentTime)
        
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
