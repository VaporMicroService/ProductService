import Foundation
import FluentPostgreSQL
import Vapor

struct ProductController {
    // MARK: Boot
    func boot(router: Router) throws {
        let route = router.grouped("products")
        route.get(use: getAllHandler)
    }
    
    
    //MARK: Main
    func getAllHandler(_ req: Request) throws -> Future<[Event]> {
        return Event.query(on: req).decode(Event.self).all()
    }
}
