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
    static func create(on connection: PostgreSQLConnection, owner: String = "1234") throws -> Vendor {
        var vendor = Vendor(ownerID: nil)
        vendor.title = "Test Name"
        vendor.assignOwner(owner)
        return try vendor.save(on: connection).wait()
    }
}

class ProductControllerTests: XCTestCase {
    static let allTests = [
        ("testGetVendor", testGetVendor),
        ("testGetAllVendor", testGetAllVendor),
        ("testGetAllOwnedVendor", testGetAllOwnedVendor),
        ("testCreateVendor", testCreateVendor),
        ("testUpdateVendor", testUpdateVendor),
        ("testDeleteVendor", testDeleteVendor),
        ("testLocationQuery", testLocationQuery),
        ("testLocationQueryNoCoordinates", testLocationQueryNoCoordinates),
        ("testLocationQueryNoDistance", testLocationQueryNoDistance),
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
    
    func testGetVendor() throws {
        let vendor = try Vendor.create(on: conn)
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/\(Vendor.name.lowercased())/\(vendor.id!)", method: .GET, headers: headers)
        XCTAssertEqual(response.http.status.code, 200)
        
        let fetch = try response.content.syncDecode(Vendor.self)
        
        XCTAssertEqual(fetch.title, vendor.title)
        XCTAssertNotNil(fetch)
    }
    
    func testGetAllVendor() throws {
        let count = 25
        for _ in 0 ..< count {
            let _ = try Vendor.create(on: conn, owner: "4321")
            let _ = try Vendor.create(on: conn)
        }
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/\(Vendor.name.lowercased())", method: .GET, headers: headers)
        XCTAssertEqual(response.http.status.code, 200)
        
        let fetch = try response.content.syncDecode([Vendor].self)
        XCTAssert(fetch.count == count * 2)
        XCTAssertNotNil(fetch)
    }
    
    func testGetAllOwnedVendor() throws {
        let count = 25
        for _ in 0 ..< count {
            let _ = try Vendor.create(on: conn, owner: "4321")
            let _ = try Vendor.create(on: conn)
        }
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/\(Vendor.name.lowercased())/owner", method: .GET, headers: headers)
        XCTAssertEqual(response.http.status.code, 200)
        
        let fetch = try response.content.syncDecode([Vendor].self)
        print(fetch.count)
        print(fetch)
        XCTAssert(fetch.count == count)
        XCTAssertNotNil(fetch)
    }

    func testCreateVendor() throws {
        let vendor = Vendor(ownerID: nil)
        vendor.title = "hdska csakjch fhewg vdsjlhvgds"
        
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/\(Vendor.name.lowercased())", method: .POST, headers: headers, body: vendor)
        XCTAssertEqual(response.http.status.code, 200)
        
        let fetch = try response.content.syncDecode(Vendor.self)
        XCTAssertTrue(fetch.ownerID?.contains("1234") == true)
        XCTAssertEqual(fetch.title, vendor.title)
        XCTAssertNotNil(fetch)
    }
    
    func testUpdateVendor() throws {
        let created = try Vendor.create(on: conn)
        
        let vendor = Vendor(ownerID: nil)
        vendor.title = "hdska csakjch fhewg vdsjlhvgds"
        
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/\(Vendor.name.lowercased())/\(created.id!)", method: .PUT, headers: headers, body: vendor)
        XCTAssertEqual(response.http.status.code, 200)
        
        let fetch = try response.content.syncDecode(Vendor.self)
        XCTAssertTrue(fetch.ownerID?.contains("1234") == true)
        XCTAssertEqual(fetch.title, vendor.title)
        XCTAssertNotNil(fetch)
    }
    
    func testDeleteVendor() throws {
        let vendor = try Vendor.create(on: conn)
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/\(Vendor.name.lowercased())/\(vendor.id!)", method: .DELETE, headers: headers)
        XCTAssertEqual(response.http.status.code, 204)
    }
    
    func testLocationQuery() throws {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/events?distance=10000&geoPoint%5Blongitude%5D=151.211&geoPoint%5Blatitude%5D=-33.8634", method: .GET, headers: headers)
        XCTAssertEqual(response.http.status.code, 200)
    }
    
    func testLocationQueryNoCoordinates() throws {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/events?distance=10000", method: .GET, headers: headers)
        XCTAssertEqual(response.http.status.code, 400)
    }
    
    func testLocationQueryNoDistance() throws {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentID, value: "1234")
        let response = try app.sendRequest(to: "festivals/events?geoPoint%5Blongitude%5D=151.211&geoPoint%5Blatitude%5D=-33.8634", method: .GET, headers: headers)
        XCTAssertEqual(response.http.status.code, 400)
    }
}
