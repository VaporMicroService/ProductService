import Foundation
import FluentPostgreSQL
import Vapor

enum ProductType: Int, PostgreSQLRawEnum {
    case wine
    case beer
    case spirits
    case soft
    case food
    case unknown
}

final class Product: VaporModel {
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    var id: Int?
    var ownerID: [String]?
    var createdAt: Date?
    var updatedAt: Date?
    var name: String?
    var description: String?
    var type: ProductType = .unknown
    var alcohol: Float?
    var capacity: Int?
    var rating: Double?
    var price: Double?
    var limit: Int?
    var image: URL?
    
    init(id: Int? = nil, ownerID: [String]?) {
        self.id = id
        self.ownerID = ownerID
    }
    
    func update(_ model: Product) throws {
        name = model.name
        description = model.description
        type = model.type
        alcohol = model.alcohol
        capacity = model.capacity
        rating = model.rating
        price = model.price
        limit = model.limit
        image = model.image
    }
}

extension Product: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(Product.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.ownerID)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            builder.field(for: \.name)
            builder.field(for: \.description)
            builder.field(for: \.type)
            builder.field(for: \.alcohol)
            builder.field(for: \.capacity)
            builder.field(for: \.rating)
            builder.field(for: \.price)
            builder.field(for: \.limit)
            builder.field(for: \.image)
            
            builder.unique(on: \.id)
        }
    }
}
