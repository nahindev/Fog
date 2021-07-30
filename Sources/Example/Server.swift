import Fog
import Vapor

//@main
struct Server {
//    static func main() throws {
//        try app().run()
//    }
    
    static func app() throws -> ApplicationController {
        let routes: [RouteCollection] = [
            UserRoutes(),
        ]
        
        let services: [Service.Type] = [
            UserService.self,
        ]
        
        return try ApplicationController(routes: routes, services: services) { (application) in
            // Do additional configuration
        }
    }
}
