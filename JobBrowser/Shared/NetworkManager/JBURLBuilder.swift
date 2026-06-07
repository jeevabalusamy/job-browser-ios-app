//
//  JBURLBuilder.swift
//  JobBrowser
//

import Foundation

/// Defines the URL schemes available.
enum JBURLScheme: String {
    case http
    case https
}

/// Defines the environments for the API to easily switch hosts.
enum JBEnvironment {
    case development
    case staging
    case production
    
    /// The default environment based on the build configuration.
    static var current: JBEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    var host: String {
        switch self {
        case .development: return "6a2311725c610353286ab01b.mockapi.io"
        case .staging: return "6a2311725c610353286ab01b.mockapi.io"
        case .production: return "6a2311725c610353286ab01b.mockapi.io"
        }
    }
}

/// A builder class to construct `URL`s safely and progressively.
final class JBURLBuilder {
    private var components: URLComponents
    
    init() {
        self.components = URLComponents()
        // Set default scheme and host
        self.components.scheme = JBURLScheme.https.rawValue
        self.components.host = JBEnvironment.current.host
    }
    
    /// Sets the URL scheme.
    @discardableResult
    func set(scheme: JBURLScheme) -> Self {
        components.scheme = scheme.rawValue
        return self
    }
    
    /// Sets the host based on the provided environment.
    @discardableResult
    func set(environment: JBEnvironment) -> Self {
        components.host = environment.host
        return self
    }
    
    /// Sets the path for the URL.
    @discardableResult
    func set(path: String) -> Self {
        components.path = path.hasPrefix("/") ? path : "/\(path)"
        return self
    }
    
    /// Adds a single query item.
    @discardableResult
    func addQueryItem(name: String, value: String?) -> Self {
        if components.queryItems == nil {
            components.queryItems = []
        }
        components.queryItems?.append(URLQueryItem(name: name, value: value))
        return self
    }
    
    /// Sets multiple query items, replacing any existing ones.
    @discardableResult
    func setQueryItems(_ parameters: [String: String?]) -> Self {
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return self
    }
    
    /// Builds and returns the final `URL`.
    /// - Throws: `JBNetworkError.invalidURL` if the resulting URL is invalid.
    func build() throws -> URL {
        guard let url = components.url else {
            // Re-using the invalidURL error from JBNetworkError
            throw JBNetworkError.invalidURL
        }
        return url
    }
}
