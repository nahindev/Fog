import Vapor
import Fog
@testable import Example

class UserServiceMock: UserServiceProtocol {
    var application: Application
    var id: ServiceID
    
    required init(application: Application) {
        self.application = application
        self.id = .user
    }
    
    var userMock: ((String) -> User?)?
    func user(id: String) -> EventLoopFuture<User?> {
        guard let userMock = userMock else { fatalError("calling mocked func without mock") }
        return application.eventLoopGroup.future(userMock(id))
    }
    
    var usersMock: (() -> [User])?
    func users() -> EventLoopFuture<[User]> {
        guard let usersMock = usersMock else { fatalError("calling mocked func without mock")}
        return application.eventLoopGroup.future(usersMock())
    }
    
    var addUserMock: ((String) -> Result<User, UserServiceError>)?
    func addUser(name: String) -> EventLoopFuture<(Result<User, UserServiceError>)> {
        guard let addUserMock = addUserMock else { fatalError("calling mocked func without mock")}
        return application.eventLoopGroup.future(addUserMock(name))
    }
}
