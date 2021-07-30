import Quick
import Nimble
import Vapor
@testable import Example

class UserServiceSpec: QuickSpec {
    override func spec() {
        describe("UserServiceSpec") {
            var service: UserService!
            
            beforeEach {
                let application = Application(.testing)
                service = UserService(application: application)
            }
            
            afterEach {
                service.application.shutdown()
            }
            
            it("should return nil if no users") {
                let user = try service.user(id: "id-1").wait()
                expect(user).to(beNil())
            }
            
            it("should return the user if added") {
                switch try service.addUser(name: "Name").wait() {
                case .success(let newUser):
                    let user = try service.user(id: newUser.id).wait()
                    expect(user?.name) == "Name"
                case .failure(_):
                    fail("Should not have returned an error")
                }
            }
            
            it("should return an empty array if no users") {
                let users = try service.users().wait()
                expect(users.count) == 0
            }
            
            it("should return the number of users added") {
                _ = try service.addUser(name: "Name").wait()
                _ = try service.addUser(name: "Name Clone").wait()
                let users = try service.users().wait()
                
                expect(users.count) == 2
            }
        }
    }
}
