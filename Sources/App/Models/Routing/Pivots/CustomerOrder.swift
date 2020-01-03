import Foundation
import FluentPostgreSQL
import Vapor

final class CustomerOrder: VaporPivot {
    static let leftIDKey: LeftIDKey = \.customerID
    static let rightIDKey: RightIDKey = \.orderID
    
    typealias Left = Customer
    typealias Right = Order
    
    var id: Int?
    var orderID: Int
    var customerID: Int
    
    init(_ left: Customer, _ right: Order) throws {
        customerID = try left.requireID()
        orderID = try right.requireID()
    }
}

extension CustomerOrder: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(CustomerOrder.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.orderID)
            builder.field(for: \.customerID)
            builder.reference(from: \.orderID, to: \Order.id)
            builder.reference(from: \.customerID, to: \Customer.id)
        }
    }
}

