import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    private init() {
        // Замените URL и ключ на ваши данные из Supabase
        client = SupabaseClient(
            supabaseURL: URL(string: "https://ylpgpkphvlyhvsgoebpc.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlscGdwa3Bodmx5aHZzZ29lYnBjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyNDQ4NjYsImV4cCI6MjA2MDgyMDg2Nn0.np9lnOsMFaIPtitkEvVDnz5F2j2DFsWVF6Oj10gh600"
        )
    }
    
    // MARK: - Coffee Shops
    
    func fetchCoffeeShops() async throws -> [CoffeeShop] {
        let response = try await client
            .database
            .from("coffee_shops")
            .select()
            .execute()
        
        return try JSONDecoder().decode([CoffeeShop].self, from: response.data)
    }
    
    // MARK: - Menu Items
    
    func fetchMenuItems(for coffeeShopId: String) async throws -> [MenuItem] {
        let response = try await client
            .database
            .from("menu_items")
            .select()
            .eq("coffee_shop_id", value: coffeeShopId)
            .execute()
        
        return try JSONDecoder().decode([MenuItem].self, from: response.data)
    }
    
    // MARK: - Orders
    
    func createOrder(_ order: Order) async throws -> Order {
        let response = try await client
            .database
            .from("orders")
            .insert(order)
            .select()
            .single()
            .execute()
        
        return try JSONDecoder().decode(Order.self, from: response.data)
    }
    
    func fetchOrders(for userId: String) async throws -> [Order] {
        let response = try await client
            .database
            .from("orders")
            .select()
            .eq("user_id", value: userId)
            .execute()
        
        return try JSONDecoder().decode([Order].self, from: response.data)
    }
} 