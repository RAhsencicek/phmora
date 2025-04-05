import SwiftUI

struct Notification: Identifiable {
    var id = UUID()
    let title: String
    let message: String
    let date: Date
    let type: NotificationType
    var isRead: Bool = false
}

enum NotificationType {
    case offer
    case purchase
    case system
    case expiry
}

struct NotificationsView: View {
    @State private var notifications: [Notification] = [
        Notification(
            title: "Yeni Teklif",
            message: "Aspirin için 15,00 TL tutarında yeni bir teklif aldınız.",
            date: Date().addingTimeInterval(-3600),
            type: .offer
        ),
        Notification(
            title: "Sipariş Tamamlandı",
            message: "Parol siparişiniz başarıyla tamamlandı. Satıcı ile iletişime geçebilirsiniz.",
            date: Date().addingTimeInterval(-86400),
            type: .purchase
        ),
        Notification(
            title: "Son Kullanma Tarihi Yaklaşıyor",
            message: "Augmentin ilacının son kullanma tarihi 2 hafta içinde dolacak.",
            date: Date().addingTimeInterval(-172800),
            type: .expiry
        ),
        Notification(
            title: "Hoş Geldiniz",
            message: "Pharmora'ya hoş geldiniz! İlaç takası yaparak stok yönetiminizi optimize edebilirsiniz.",
            date: Date().addingTimeInterval(-259200),
            type: .system,
            isRead: true
        )
    ]
    
    var body: some View {
        List {
            if notifications.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Bildiriminiz bulunmuyor")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .listRowInsets(EdgeInsets())
                .background(Color.clear)
            } else {
                ForEach(notifications) { notification in
                    NotificationRow(notification: notification)
                        .listRowBackground(notification.isRead ? Color.white : Color(red: 0.95, green: 1.0, blue: 0.95))
                        .onTapGesture {
                            markAsRead(notification)
                        }
                }
                .onDelete(perform: deleteNotification)
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.automatic)
        #endif
        .navigationTitle("Bildirimler")
        .toolbar {
            if !notifications.isEmpty {
                Button(action: {
                    markAllAsRead()
                }) {
                    Text("Tümünü Okundu İşaretle")
                        .font(.caption)
                }
            }
        }
    }
    
    private func markAsRead(_ notification: Notification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    private func markAllAsRead() {
        for i in notifications.indices {
            notifications[i].isRead = true
        }
    }
    
    private func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
    }
}

struct NotificationRow: View {
    let notification: Notification
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: iconForType(notification.type))
                .font(.title2)
                .foregroundColor(colorForType(notification.type))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.isRead ? .primary : Color(red: 0.4, green: 0.5, blue: 0.4))
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Text(timeAgo(from: notification.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(colorForType(notification.type))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func iconForType(_ type: NotificationType) -> String {
        switch type {
        case .offer:
            return "text.badge.plus"
        case .purchase:
            return "bag"
        case .system:
            return "bell"
        case .expiry:
            return "calendar"
        }
    }
    
    private func colorForType(_ type: NotificationType) -> Color {
        switch type {
        case .offer:
            return Color.blue
        case .purchase:
            return Color(red: 0.4, green: 0.5, blue: 0.4)
        case .system:
            return Color.orange
        case .expiry:
            return Color.red
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "1 gün önce" : "\(day) gün önce"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 saat önce" : "\(hour) saat önce"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 dakika önce" : "\(minute) dakika önce"
        } else {
            return "Az önce"
        }
    }
}

#Preview {
    NavigationView {
        NotificationsView()
    }
} 