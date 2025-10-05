import SwiftUI

struct OrdersView: View {
    @EnvironmentObject private var orderManager: OrderManager
    @State private var selectedTab: OrderTab = .active
    
    enum OrderTab: String, CaseIterable {
        case active = "Active"
        case past = "Past"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Order Type", selection: $selectedTab) {
                    ForEach(OrderTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case .active:
                        activeOrdersView
                    case .past:
                        pastOrdersView
                    }
                }
            }
            .navigationTitle("Your Orders")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var activeOrdersView: some View {
        Group {
            if orderManager.activeOrders.isEmpty {
                emptyActiveOrdersView
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(orderManager.activeOrders) { order in
                            ActiveOrderCard(order: order)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var pastOrdersView: some View {
        Group {
            if orderManager.orders.filter({ !$0.isActive }).isEmpty {
                emptyPastOrdersView
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(orderManager.orders.filter { !$0.isActive }) { order in
                            PastOrderCard(order: order)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var emptyActiveOrdersView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("No active orders")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Your active orders will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    private var emptyPastOrdersView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("No past orders")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Your order history will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
}

struct ActiveOrderCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.orderNumber)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Coffee Shop") // TODO: Add coffee shop name lookup
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                OrderStatusBadge(status: order.status)
            }
            
            // Progress Indicator
            OrderProgressView(status: order.status)
            
            // Estimated pickup time
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("Ready by \(order.estimatedPickupTime, style: .time)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            // Items preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Items:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(Array(order.items.prefix(3)), id: \.id) { item in
                    HStack {
                        Text("\(item.quantity)x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.menuItem.name)
                            .font(.caption)
                        Spacer()
                    }
                }
                
                if order.items.count > 3 {
                    Text("+ \(order.items.count - 3) more items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Total
            HStack {
                Spacer()
                Text("Total: $\(order.total, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct PastOrderCard: View {
    let order: Order
    @State private var showingReorder = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.orderNumber)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Coffee Shop") // TODO: Add coffee shop name lookup
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let completedDate = order.actualPickupTime {
                        Text(completedDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    OrderStatusBadge(status: order.status)
                    Text("$\(order.total, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            // Items preview
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(order.items.prefix(2)), id: \.id) { item in
                    Text("\(item.quantity)x \(item.menuItem.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if order.items.count > 2 {
                    Text("+ \(order.items.count - 2) more items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Actions
            HStack {
                Button("View Details") {
                    // TODO: Show order details
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Reorder") {
                    showingReorder = true
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .alert("Reorder Items", isPresented: $showingReorder) {
            Button("Add to Cart") {
                // TODO: Add items to cart
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Add all items from this order to your cart?")
        }
    }
}

struct OrderStatusBadge: View {
    let status: OrderStatus
    
    private var badgeColor: Color {
        switch status {
        case .placed:
            return .orange
        case .confirmed:
            return .blue
        case .preparing:
            return .purple
        case .ready:
            return .green
        case .completed:
            return .gray
        case .cancelled:
            return .red
        }
    }
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

struct OrderProgressView: View {
    let status: OrderStatus
    
    private let progressSteps: [OrderStatus] = [.placed, .confirmed, .preparing, .ready]
    
    private var currentStepIndex: Int {
        progressSteps.firstIndex(of: status) ?? 0
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(progressSteps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 0) {
                    // Step circle
                    Circle()
                        .fill(index <= currentStepIndex ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    // Connecting line (except for last item)
                    if index < progressSteps.count - 1 {
                        Rectangle()
                            .fill(index < currentStepIndex ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// Extension to provide display names for order status
extension OrderStatus {
    var displayName: String {
        switch self {
        case .placed:
            return "Placed"
        case .confirmed:
            return "Confirmed"
        case .preparing:
            return "Preparing"
        case .ready:
            return "Ready"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
}

#Preview {
    OrdersView()
        .environmentObject(OrderManager())
}