import Foundation
import FluentPostgreSQL
import Vapor

struct MainController<Model: VaporModel> {
    // MARK: Boot
    func boot(router: Router) throws {
        print("🚀🚀🚀 Adding routes for: \(Model.name)")
        let route = router.grouped(Model.name.lowercased())
        
        route.get(Model.parameter, use: getOneHandler)
        route.get(use: getAllHandler)
        route.get("owner", use: getAllByOwnerHandler)
        route.post(use: createHandler)
        route.put(Model.parameter, use: updateHandler)
        route.delete(Model.parameter, use: deleteHandler)
    }
    
    
    //MARK: Main
    func getOneHandler(_ req: Request) throws -> Future<Model> {
        return try req.parameters.next(Model.self) as! EventLoopFuture<Model>
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Model]> {
        let pagination = try req.query.decode(Pagination.self)
        let startIndex = pagination.offset ?? 0
        let length = pagination.length ?? 50
        let endIndex = startIndex + length
        return Model.query(on: req).decode(Model.self).range(startIndex ..< endIndex).all()
    }
    
    func getAllByOwnerHandler(_ req: Request) throws -> Future<[Model]> {
        guard let ownerId = req.http.headers.firstValue(name: .contentID) else { throw Abort(.badRequest) }
        let pagination = try req.query.decode(Pagination.self)
        let startIndex = pagination.offset ?? 0
        let length = pagination.length ?? 50
        let endIndex = startIndex + length
        
        return Model.query(on: req)
            .filter(PostgreSQLColumnIdentifier.keyPath(\Model.ownerID), .contains, ownerId)
            .range(startIndex ..< endIndex)
            .all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Model> {
        guard let ownerId = req.http.headers.firstValue(name: .contentID) else { throw Abort(.unauthorized) }
        return try req.content.decode(Model.self, using: decoderJSON).flatMap { model in
            var newModel = model
            newModel.assignOwner(ownerId)
            return newModel.save(on: req)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Model> {
        guard let ownerId = req.http.headers.firstValue(name: .contentID) else { throw Abort(.unauthorized) }
        return try flatMap(to: Model.self, req.parameters.next(Model.self) as! EventLoopFuture<Model>, req.content.decode(Model.self, using: decoderJSON)) { (model, updatedModel) in
            guard model.ownerID?.contains(ownerId) ?? false else { throw Abort(.forbidden) }
            try model.update(updatedModel)
            return model.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        guard let ownerId = req.http.headers.firstValue(name: .contentID) else { throw Abort(.unauthorized) }
        return (try req.parameters.next(Model.self) as! EventLoopFuture<Model>).flatMap { model in
            guard model.ownerID?.contains(ownerId) ?? false else { throw Abort(.forbidden) }
            return model.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
}
