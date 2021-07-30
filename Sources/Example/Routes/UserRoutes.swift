import Vapor

struct UserRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("users") { users in
            users.get("", use: all)
            users.get(":id", use: get)
            users.post("add", use: add)
        }
    }
    
    func all(request: Request) -> EventLoopFuture<[User]> {
        request.application.services.user.users()
    }
    
    func get(request: Request) throws -> EventLoopFuture<User> {
        guard let id = request.parameters.get("id") else {
            throw Abort(.notFound)
        }
        return request.application.services.user.user(id: id)
            .unwrap(or: Abort(.notFound))
    }
    
    struct AddInput: Content {
        let name: String
    }
    
    func add(request: Request) throws -> EventLoopFuture<User> {
        guard let input = try? request.content.decode(AddInput.self) else {
            throw Abort(.badRequest)
        }
        
        return request.application.services.user.addUser(name: input.name)
            .flatMapThrowing { result in
                switch result {
                case .success(let user): return user
                case .failure(let error):
                    request.application.logger.error("\(error.localizedDescription)")
                    throw Abort(.noContent)
                }
            }
    }
}
