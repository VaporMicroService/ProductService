import Foundation
import FluentPostgreSQL
import Vapor

final class OrderProduct: VaporPivot {
    static let leftIDKey: LeftIDKey = \.orderID
    static let rightIDKey: RightIDKey = \.productID
    
    typealias Left = Order
    typealias Right = Product
    
    var id: Int?
    var orderID: Int
    var productID: Int
    
    init(_ left: Order, _ right: Product) throws {
        orderID = try left.requireID()
        productID = try right.requireID()
    }
}

extension OrderProduct: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(OrderProduct.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.orderID)
            builder.field(for: \.productID)
            builder.reference(from: \.orderID, to: \Order.id)
            builder.reference(from: \.productID, to: \Product.id)
        }
    }
}
