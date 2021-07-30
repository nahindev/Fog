import GRPC
import Vapor

extension Application {
    public struct GRPC {
        let application: Application
    }
    
    public var grpc: GRPC { GRPC(application: self) }
}

extension Application.GRPC {
    public struct Server {
        let application: Application
    }
    
    public var server: Server { Server(application: application) }
}

extension Application.GRPC.Server {
    struct ServerKey: StorageKey {
        typealias Value = GRPCServer
    }
    
    struct ConfigurationKey: StorageKey {
        typealias Value = GRPCServer.Configuration
    }
    
    public var configuration: GRPCServer.Configuration {
        get {
            if let existing = application.storage[ConfigurationKey.self] {
                return existing
            } else {
                return GRPCServer.Configuration()
            }
        }
        
        nonmutating set {
            if application.storage.contains(ServerKey.self) {
                application.logger.warning("Cannot modify server configuration after server exists")
            } else {
                application.storage[ConfigurationKey.self] = newValue
            }
        }
    }
    
    var shared: GRPCServer {
        if let existing = application.storage[ServerKey.self] {
            return existing
        } else {
            let new = GRPCServer(application: application, configuration: configuration)
            application.storage[ServerKey.self] = new
            return new
        }
    }
}

extension Application.Servers.Provider {
    public static var grpc: Self {
        Application.Servers.Provider { (application) in
            application.servers.use { (application) in
                application.grpc.server.shared
            }
        }
    }
}
