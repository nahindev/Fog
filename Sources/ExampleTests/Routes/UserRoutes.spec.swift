import Quick
import Nimble
import Vapor
import XCTVapor
import Fog
@testable import Example

class UserRoutesSpec: QuickSpec {
    override func spec() {
        describe("UserRoutes") {
            var application: Application!
            var mock: UserServiceMock!
            var routes: UserRoutes!
            
            beforeEach {
                application = Application(.testing)
                mock = UserServiceMock(application: application)
                routes = UserRoutes()
                application.services.add(mock)
                try! application.register(collection: routes)
            }
            
            afterEach {
                application.shutdown()
            }
            
            it("should return an empty arrary if no users") {
                mock.usersMock = {
                    return []
                }
                
                try application.test(.GET, "users") { res in
                    expect(res.status) == .ok
                    expect(res.body.string) == "[]"
                }
            }
            
            it("should return all users from the service") {
                mock.usersMock = {
                    return [User(id: "id-1", name: "Name")]
                }
                
                try application.test(.GET, "users") { res in
                    expect(res.status) == .ok
                    expect(res.body.string) == "[{\"id\":\"id-1\",\"name\":\"Name\"}]"
                }
            }
            
            it("should return an error if no user found") {
                mock.userMock = { _ in
                    return nil
                }
                
                try application.test(.GET, "users/id-1") { res in
                    expect(res.status) == .notFound
                    expect(res.body.string) == "{\"error\":true,\"reason\":\"Not Found\"}"
                }
            }
            
            it("should return the user if there is one") {
                mock.userMock = { _ in
                    return User(id: "id-1", name: "Name")
                }
                
                try application.test(.GET, "users/id-1") { res in
                    expect(res.status) == .ok
                    expect(res.body.string) == "{\"id\":\"id-1\",\"name\":\"Name\"}"
                }
            }
            
            it("should return an error if add user has no name") {
                try application.test(.POST, "users/add", beforeRequest: { req in
                    try req.content.encode("")
                }, afterResponse: { res in
                    expect(res.status) == .badRequest
                })
            }
            
            it("should return an error if some error adding user") {
                mock.addUserMock = { _ in
                    return .failure(.couldNotAdd)
                }
                
                try application.test(.POST, "users/add", beforeRequest: { req in
                    try req.content.encode(["name": "Name"])
                }, afterResponse: { res in
                    expect(res.status) == .noContent
                })
            }
            
            it("should return the user that was just added") {
                mock.addUserMock = { _ in
                    return .success(User(id: "id-1", name: "Name"))
                }
                
                try application.test(.POST, "users/add", beforeRequest: { req in
                    try req.content.encode(["name": "Sami"])
                }, afterResponse: { res in
                    expect(res.status) == .ok
                    expect(res.body.string) == "{\"id\":\"id-1\",\"name\":\"Name\"}"
                })
            }
        }
    }
}
