import SwiftUI

struct NotificationsView: View {
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var transactionService = TransactionService.shared
    @State private var selectedFilter: NotificationTypeModel? = nil
    @State private var showingActionSheet = false
    @State private var selectedNotification: NotificationModel?
    @State private var confirmationNote = ""
    @State private var rejectionReason = ""
    @State private var showingConfirmDialog = false
    @State private var showingRejectDialog = false
    @State private var isProcessing = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIsSuccess = true
    
    var filteredNotifications: [NotificationModel] {
        if let filter = selectedFilter {
            return notificationService.notifications.filter { $0.type == filter }
        }
        return notificationService.notifications
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Filter buttons
                    filterSection
                    
                    // Notifications list
                    if notificationService.isLoading && notificationService.notifications.isEmpty {
                        ProgressView("Bildirimler yükleniyor...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredNotifications.isEmpty {
                        emptyStateView
                    } else {
                        notificationsList
                    }
                }
                .navigationTitle("Bildirimler")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Tümünü Okundu İşaretle") {
                            Task {
                                await notificationService.markAllAsRead()
                            }
                        }
                        .font(.caption)
                    }
                }
                .refreshable {
                    await notificationService.fetchNotifications()
                }
                .task {
                    await notificationService.fetchNotifications()
                }
                .alert("İşlem Onayı", isPresented: $showingConfirmDialog) {
                    TextField("Onay notu (isteğe bağlı)", text: $confirmationNote)
                    Button("Onayla") {
                        Task {
                            await confirmTransaction()
                        }
                    }
                    Button("İptal", role: .cancel) { }
                } message: {
                    Text("Bu işlemi onaylamak istediğinizden emin misiniz?")
                }
                .alert("İşlem Reddi", isPresented: $showingRejectDialog) {
                    TextField("Red sebebi", text: $rejectionReason)
                    Button("Reddet", role: .destructive) {
                        Task {
                            await rejectTransaction()
                        }
                    }
                    Button("İptal", role: .cancel) { }
                } message: {
                    Text("Bu işlemi reddetmek istediğinizden emin misiniz?")
                }
                
                // Toast overlay
                if showToast {
                    VStack {
                        Spacer()
                        ToastView(message: toastMessage, isSuccess: toastIsSuccess)
                            .padding(.bottom, 80)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showToast)
                }
            }
        }
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(
                    title: "Tümü",
                    isSelected: selectedFilter == nil,
                    count: notificationService.notifications.count
                ) {
                    selectedFilter = nil
                }
                
                ForEach(NotificationTypeModel.allCases, id: \.self) { type in
                    let count = notificationService.notifications.filter { $0.type == type }.count
                    if count > 0 {
                        FilterButton(
                            title: type.displayName,
                            isSelected: selectedFilter == type,
                            count: count
                        ) {
                            selectedFilter = type
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var notificationsList: some View {
        List {
            ForEach(filteredNotifications) { notification in
                NotificationRowView(
                    notification: notification,
                    onTap: {
                        Task {
                            await notificationService.markAsRead(notification.id)
                        }
                    },
                    onAction: { action in
                        handleNotificationAction(notification: notification, action: action)
                    }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Bildirim Yok")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(selectedFilter == nil ? 
                 "Henüz hiç bildiriminiz bulunmuyor." :
                 "\(selectedFilter?.displayName ?? "") türünde bildirim bulunmuyor.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func handleNotificationAction(notification: NotificationModel, action: NotificationAction) {
        selectedNotification = notification
        
        switch action {
        case .approve:
            showingConfirmDialog = true
        case .reject:
            showingRejectDialog = true
        }
    }
    
    private func confirmTransaction() async {
        guard let notification = selectedNotification,
              let transactionRef = notification.data?.transactionId else {
            return
        }
        
        isProcessing = true
        
        do {
            try await transactionService.confirmTransaction(
                transactionId: transactionRef.id,
                note: confirmationNote.isEmpty ? nil : confirmationNote
            )
            
            // Bildirimleri yenile
            await notificationService.fetchNotifications()
            
            // Form'u temizle
            confirmationNote = ""
            selectedNotification = nil
            
            // Başarı mesajı göster
            showToast(message: "İşlem başarıyla onaylandı!", isSuccess: true)
            
        } catch {
            print("❌ Transaction confirmation error: \(error)")
            showToast(message: "İşlem onaylanamadı: \(error.localizedDescription)", isSuccess: false)
        }
        
        isProcessing = false
    }
    
    private func rejectTransaction() async {
        guard let notification = selectedNotification,
              let transactionRef = notification.data?.transactionId,
              !rejectionReason.isEmpty else {
            return
        }
        
        isProcessing = true
        
        do {
            try await transactionService.rejectTransaction(
                transactionId: transactionRef.id,
                reason: rejectionReason
            )
            
            // Bildirimleri yenile
            await notificationService.fetchNotifications()
            
            // Form'u temizle
            rejectionReason = ""
            selectedNotification = nil
            
            // Başarı mesajı göster
            showToast(message: "İşlem başarıyla reddedildi!", isSuccess: true)
            
        } catch {
            print("❌ Transaction rejection error: \(error)")
            showToast(message: "İşlem reddedilemedi: \(error.localizedDescription)", isSuccess: false)
        }
        
        isProcessing = false
    }
    
    private func showToast(message: String, isSuccess: Bool) {
        toastMessage = message
        toastIsSuccess = isSuccess
        showToast = true
        
        // 3 saniye sonra toast'ı kapat
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showToast = false
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white : Color.gray.opacity(0.3))
                        .foregroundColor(isSelected ? Color(red: 0.4, green: 0.5, blue: 0.4) : .gray)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color(red: 0.4, green: 0.5, blue: 0.4) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

enum NotificationAction {
    case approve
    case reject
}

struct NotificationRowView: View {
    let notification: NotificationModel
    let onTap: () -> Void
    let onAction: (NotificationAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: notification.type.iconName)
                    .foregroundColor(notification.type.color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(notification.title)
                        .font(.headline)
                        .fontWeight(notification.isRead ? .medium : .bold)
                    
                    Text(formatDate(notification.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if !notification.isRead {
                    Circle()
                        .fill(Color(red: 0.4, green: 0.5, blue: 0.4))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Message
            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Action buttons for offer notifications
            if notification.type == .offer && notification.data?.transactionId != nil {
                // Eğer işlem durumu varsa ve onaylanmış/reddedilmiş ise durumu göster
                if let status = notification.data?.transactionId?.status, status != "pending" {
                    HStack(spacing: 8) {
                        if status == "confirmed" || status == "completed" {
                            Label("Onaylandı", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(red: 0.4, green: 0.5, blue: 0.4).opacity(0.1))
                                .cornerRadius(8)
                        } else if status == "cancelled" || status == "rejected" {
                            Label("Reddedildi", systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        } else if status == "in_transit" {
                            Label("Sevkiyatta", systemImage: "shippingbox.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        } else if status == "delivered" {
                            Label("Teslim Edildi", systemImage: "hands.clap.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            Label(status.capitalized, systemImage: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                } else {
                    // Henüz işlenmemiş teklif bildirimi - onay/red butonlarını göster
                    HStack(spacing: 12) {
                        Button("Onayla") {
                            onAction(.approve)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.4, green: 0.5, blue: 0.4))
                        .font(.caption)
                        
                        Button("Reddet") {
                            onAction(.reject)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .font(.caption)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(notification.isRead ? Color(.systemBackground) : Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NotificationsView()
}

// Toast mesajı için özel view
struct ToastView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSuccess ? Color(red: 0.4, green: 0.5, blue: 0.4) : Color.red)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }
} 