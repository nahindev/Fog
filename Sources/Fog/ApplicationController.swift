import Vapor

public struct ApplicationController {
    public let application: Application
    
    public init() throws {
        var environment = try Environment.detect()
        try LoggingSystem.bootstrap(from: &environment)
        self.application = Application(environment)
    }
    
    public init(routes: [RouteCollection] = [], services: [Service.Type] = [], configure: (Application) throws -> Void) throws {
        try self.init()
        try configureRoutes(routes: routes)
        configureServices(services: services)
        try configure(application)
    }
    
    public func run() throws {
        defer { application.shutdown() }
        try application.run()
    }
    
    public func configureRoutes(routes: [RouteCollection]) throws {
        application.servers.use(.http)
        application.http.server.configuration.hostname = "0.0.0.0"
        application.http.server.configuration.port = 8080
        
        try routes.forEach { try application.register(collection: $0) }
    }
    
    public func configureServices(services: [Service.Type]) {
        application.services.add(services)
    }
}
