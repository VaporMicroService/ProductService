//
//  ProductVendor.swift
//  App
//
//  Created by Szymon Lorenz on 3/1/20.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class VendorProduct: VaporPivot {
    static let leftIDKey: LeftIDKey = \.vendorID
    static let rightIDKey: RightIDKey = \.productID
    
    typealias Left = Vendor
    typealias Right = Product
    
    var id: Int?
    var vendorID: Int
    var productID: Int
    
    init(_ left: Vendor, _ right: Product) throws {
        vendorID = try left.requireID()
        productID = try right.requireID()
    }
}

extension VendorProduct: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(VendorProduct.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.productID)
            builder.field(for: \.vendorID)
            builder.reference(from: \.productID, to: \Product.id)
            builder.reference(from: \.vendorID, to: \Vendor.id)
        }
    }
}
