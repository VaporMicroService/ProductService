import Foundation
import FluentPostgreSQL
import FluentPostGIS
import Vapor
import Avenue

final class Event: VaporSibling {    
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    var id: Int?
    var vendorID: Vendor.ID!
    var createdAt: Date?
    var updatedAt: Date?
    
    var title: String?
    var description: String?
    var startTime: Date?
    var endTime: Date?
    var image: URL?
    var location: GeographicPoint2D?
    
    init(id: Int? = nil, vendorID: Vendor.ID) {
        self.id = id
        self.vendorID = vendorID
    }
    
    func update(_ model: Event) throws {
        title = model.title
        description = model.description
        startTime = model.startTime
        endTime = model.endTime
        image = model.image
        location = model.location
    }
    
    func isAttached<T>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<Bool> where T : Model {
        return lists.isAttached(model as! List, on: conn)
    }
    
    func attach<T, P>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<P?> where T : Model, P : VaporPivot {
        return lists.attach(model as! List, on: conn).map { pivot -> P? in
            return pivot as? P
        }
    }
    
    func detach<T>(_ model: T, on conn: DatabaseConnectable) -> EventLoopFuture<Void> where T : Model {
        return lists.detach(model as! List, on: conn)
    }
}

extension Event {
    var vendor: Parent<Event, Vendor> {
        return parent(\.vendorID)
    }
    
    var lists: Siblings<Event, List, EventProductList> {
        return siblings()
    }
}

extension Event: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(Event.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.vendorID)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            
            builder.field(for: \.title)
            builder.field(for: \.description)
            builder.field(for: \.startTime)
            builder.field(for: \.endTime)
            builder.field(for: \.image)
            builder.field(for: \.location)
            
            builder.reference(from: \.vendorID, to: \Vendor.id, onDelete: .cascade)
            builder.unique(on: \.id)
        }
    }
}
