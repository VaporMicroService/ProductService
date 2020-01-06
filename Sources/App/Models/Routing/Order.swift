import Foundation
import FluentPostgreSQL
import Vapor

enum OrderStatus: Int, PostgreSQLRawEnum {
    case pending
    case prepare
    case ready
    case delivered
}

final class Order: VaporSibling {
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    var id: Int?
    var customerID: Customer.ID
    var vendorID: Vendor.ID
    var createdAt: Date?
    var updatedAt: Date?
    var name: String?
    var description: String?
    var status: OrderStatus = .pending
    
    func update(_ model: Order) throws {
        
    }
    
    func isAttached<T>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<Bool> where T : PostgreSQLModel {
        return products.isAttached(model as! Product, on: conn)
    }
    
    func attach<T, P>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<P?> where T : PostgreSQLModel, P : VaporPivot {
        return products.attach(model as! Product, on: conn).map { pivot -> P? in
            return pivot as? P
        }
    }
    
    func detach<T>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<Void> where T : PostgreSQLModel {
        return products.detach(model as! Product, on: conn)
    }
}

extension Order {
    var customer: Parent<Order, Customer> {
        return parent(\.customerID)
    }
    
    var vendor: Parent<Order, Vendor> {
        return parent(\.vendorID)
    }
    
    var products: Siblings<Order, Product, OrderProduct> {
        return siblings()
    }
}

extension Order: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(Order.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.customerID)
            builder.field(for: \.vendorID)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            builder.field(for: \.name)
            builder.field(for: \.description)
            builder.field(for: \.status)
            
            builder.reference(from: \.customerID, to: \Customer.id, onDelete: .cascade)
            builder.reference(from: \.vendorID, to: \Vendor.id, onDelete: .cascade)
            builder.unique(on: \.id)
        }
    }
}
