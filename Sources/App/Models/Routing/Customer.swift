import Foundation
import FluentPostgreSQL
import Vapor

final class Customer: VaporSibling {
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    var id: Int?
    var ownerID: [String]?
    var createdAt: Date?
    var updatedAt: Date?
    var timestamp: Date = Date()
    
    init(id: Int? = nil, ownerID: [String]?) {
        self.id = id
        self.ownerID = ownerID
    }
    
    func update(_ model: Customer) throws {}
    
    func isAttached<T>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<Bool> where T : PostgreSQLModel {
        return orders.isAttached(model as! Order, on: conn)
    }
    
    func attach<T, P>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<P?> where T : PostgreSQLModel, P : VaporPivot {
        return orders.attach(model as! Order, on: conn).map { pivot -> P? in
            return pivot as? P
        }
    }
    
    func detach<T>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<Void> where T : PostgreSQLModel {
        return orders.detach(model as! Order, on: conn)
    }
}

extension Customer {
    var events: Children<Customer, Order> {
        return children(\Order.customerID)
    }
    
    var orders: Siblings<Customer, Order, CustomerOrder> {
        return siblings()
    }
}

extension Customer: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(Customer.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.ownerID)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            builder.field(for: \.timestamp)
            
            builder.unique(on: \.id)
        }
    }
}
