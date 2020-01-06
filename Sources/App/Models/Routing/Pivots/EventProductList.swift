import Foundation
import FluentPostgreSQL
import Vapor
import Avenue

final class EventProductList: VaporPivot {
    static let leftIDKey: LeftIDKey = \.eventID
    static let rightIDKey: RightIDKey = \.listID
    
    typealias Left = Event
    typealias Right = List
    
    var id: Int?
    var eventID: Int
    var listID: Int
    
    init(_ left: Event, _ right: List) throws {
        eventID = try left.requireID()
        listID = try right.requireID()
    }
}

extension EventProductList: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(EventProductList.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.eventID)
            builder.field(for: \.listID)
            builder.reference(from: \.eventID, to: \Event.id)
            builder.reference(from: \.listID, to: \List.id)
        }
    }
}
