import Foundation
import FluentPostgreSQL
import Vapor

final class Vendor: VaporSibling {
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    var id: Int?
    var ownerID: [String]?
    var createdAt: Date?
    var updatedAt: Date?
    var name: String?
    
    init(id: Int? = nil, ownerID: [String]?) {
        self.id = id
        self.ownerID = ownerID
    }
    
    func update(_ model: Vendor) throws {
        name = model.name
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

extension Vendor {
    var events: Children<Vendor, Event> {
        return children(\Event.vendorID)
    }
    
    var lists: Children<Vendor, List> {
        return children(\List.vendorID)
    }
    
    var products: Siblings<Vendor, Product, VendorProduct> {
        return siblings()
    }
}

extension Vendor: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(Vendor.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.ownerID)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            builder.field(for: \.name)
            
            builder.unique(on: \.id)
        }
    }
}
