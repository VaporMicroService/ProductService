import Foundation
import FluentPostgreSQL
import FluentPostGIS
import Vapor
import Avenue

struct Filter: Decodable {
    var pagination: Pagination?
    var geoPoint: GeographicPoint2D
    var distance: Double
}

struct ProductController {
    // MARK: Boot
    func boot(router: Router) throws {
        let route = router.grouped("events")
        route.get(use: getAllEventsByLocation)
    }
    
    
    //MARK: Main
    func getAllEventsByLocation(_ req: Request) throws -> Future<[Event]> {
        let filter = try req.query.decode(Filter.self)
        let startIndex = filter.pagination?.offset ?? 0
        let length = filter.pagination?.length ?? 50
        let endIndex = startIndex + length
        
        return Event.query(on: req)
            .decode(Event.self)
            .filter(\Event.location != nil)
            .filterGeometryDistanceWithin(\Event.location!, filter.geoPoint, filter.distance)
            .range(startIndex ..< endIndex).all()
    }
}
