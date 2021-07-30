import Fog
import Vapor

enum UserServiceError: Error {
    case couldNotAdd
}

protocol UserServiceProtocol: Service {
    func user(id: String) -> EventLoopFuture<User?>
    func users() -> EventLoopFuture<[User]>
    func addUser(name: String) -> EventLoopFuture<(Result<User, UserServiceError>)>
}

class UserService: UserServiceProtocol {
    let application: Application
    let id: ServiceID = .user
    private var db: [User] = [] // Fake users till a database example is added
    
    required init(application: Application) {
        self.application = application
    }
    
    func user(id: String) -> EventLoopFuture<User?> {
        application.eventLoopGroup.future(db.first(where: { $0.id == id }))
    }
    
    func users() -> EventLoopFuture<[User]> {
        application.eventLoopGroup.future(db)
    }
    
    func addUser(name: String) -> EventLoopFuture<(Result<User, UserServiceError>)> {
        let user = User(id: "id-\(db.count + 1)", name: name)
        db.append(user)
        return application.eventLoopGroup.future(.success(user))
    }
}

extension ServiceID {
    static let user = ServiceID("user")
}

extension Application.Services {
    var user: UserServiceProtocol { service(.user) }
}
