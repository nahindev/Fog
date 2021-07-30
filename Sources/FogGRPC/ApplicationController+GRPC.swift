import Fog
import Vapor

extension ApplicationController {
    public init(providers: [VaporCallHandlerProvider.Type], services: [Service.Type] = [], configure: (Application) throws -> Void) throws {
        try self.init()
        configureGRPC(providers: providers)
        configureServices(services: services)
        try configure(application)
    }
    
    private func configureGRPC(providers: [VaporCallHandlerProvider.Type]) {
        application.servers.use(.grpc)
        application.grpc.server.configuration.hostname = "0.0.0.0"
        application.grpc.server.configuration.port = 8080
        
        application.grpc.server.configuration.providers = providers
            .map { $0.init(application: application) }
    }
}
