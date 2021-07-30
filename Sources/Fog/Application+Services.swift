import Vapor

public struct ServiceID: Hashable {
    let id: String
    
    public init(_ id: String) {
        self.id = id
    }
}

public protocol Service {
    init(application: Application)
    var application: Application { get }
    var id: ServiceID { get }
}

extension Application {
    public struct Services {
        let application: Application
    }
    
    public var services: Services { Services(application: self) }
}

extension Application.Services {
    struct ServicesKey: StorageKey {
        typealias Value = [ServiceID: Service]
    }
    
    public func add(_ service: Service) {
        createStorageIfNeeded()
        application.storage[ServicesKey.self]?[service.id] = service
    }
    
    public func add(_ services: [Service.Type]) {
        services
            .map { $0.init(application: self.application) }
            .forEach { self.add($0) }
    }
    
    public func service<T>(_ id: ServiceID) -> T {
        guard let service = application.storage[ServicesKey.self]?[id] else {
            fatalError("Trying to access service \(id.id) that was not set.")
        }
        
        guard let specificService = service as? T else {
            fatalError("Trying to convert service to \(T.self) failed")
        }
        
        return specificService
    }
    
    private func createStorageIfNeeded() {
        if application.storage[ServicesKey.self] == nil {
            application.storage[ServicesKey.self] = [:]
        }
    }
}
