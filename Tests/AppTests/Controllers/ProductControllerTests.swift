//
//  VendorControllerTests.swift
//  AppTests
//
//  Created by Szymon Lorenz on 25/11/19.
//

import Foundation
import Vapor
import XCTest
import FluentPostgreSQL
@testable import App

extension Vendor {
    static func create(on connection: PostgreSQLConnection) throws -> Vendor {
        var vendor = Vendor(ownerID: nil)
        vendor.title = "Test Name"
        vendor.assignOwner("1234")
        return try vendor.save(on: connection).wait()
    }
}

class ProductControllerTests: XCTestCase {
    static let allTests = [
        ("testExample", testExample),
    ]
    
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
        try? app.syncShutdownGracefully()
    }
    
    func testExample() {
        
    }
}
