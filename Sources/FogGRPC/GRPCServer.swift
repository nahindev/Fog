import GRPC
import NIO
import Vapor

public protocol VaporCallHandlerProvider: CallHandlerProvider {
    var application: Application { get }
    init(application: Application)
}

public final class GRPCServer {
    public struct Configuration {
        public var hostname: String
        public var port: Int
        public var providers: [CallHandlerProvider]
        
        init(
            hostname: String = "0.0.0.0",
            port: Int = 8080,
            providers: [CallHandlerProvider] = []
        ) {
            self.hostname = hostname
            self.port = port
            self.providers = providers
        }
    }
    
    private let configuration: Configuration
    private let application: Application
    private var server: GRPC.Server?
    private var didStart: Bool = false
    private var didShutdown: Bool = false
    
    init(application: Application, configuration: Configuration) {
        self.application = application
        self.configuration = configuration
    }
    
    deinit {
        assert(!didStart || didShutdown, "GRPCServer did not shutdown before deinit")
    }
}

extension GRPCServer: Vapor.Server {
    public func start(address: BindAddress?) throws {
        let configuration = GRPC.Server.Configuration.default(
            target: address.bindTarget(configuration: self.configuration),
            eventLoopGroup: application.eventLoopGroup,
            serviceProviders: self.configuration.providers)
        
        let server = GRPC.Server.start(configuration: configuration)
        
        server
            .map { $0.channel.localAddress }
            .whenSuccess { [application] (address) in
                if let address = address {
                    application.logger.notice("GRPCServer started on \(address)")
                } else {
                    application.logger.error("GRPCServer started but address unknown")
                }
            }
        
        self.server = try server.wait()
        self.didStart = true
    }
    
    public var onShutdown: EventLoopFuture<Void> {
        guard let server = server else { fatalError("GRPC erver not started yet") }
        return server.channel.closeFuture
    }
    
    public func shutdown() {
        guard let server = server else { return }
        application.logger.notice("GRPCServer shutting down")
        
        do {
            try server.close().wait()
            application.logger.debug("GRPCServer shutdown")
            didShutdown = true
        } catch {
            application.logger.error("Could not stop GRPCServer: \(error)")
        }
    }
}

extension Optional where Wrapped == Vapor.BindAddress {
    func bindTarget(configuration: GRPCServer.Configuration) -> GRPC.BindTarget {
        switch self {
        case .none:
            return .hostAndPort(configuration.hostname, configuration.port)
        case .hostname(let hostname, port: let port):
            return .hostAndPort(hostname ?? configuration.hostname, port ?? configuration.port)
        case .unixDomainSocket(path: let path):
            return .unixDomainSocket(path)
        }
    }
}
