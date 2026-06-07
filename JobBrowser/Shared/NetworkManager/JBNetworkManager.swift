//
//  JBNetworkManager.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 07/06/26.
//

import Foundation

/// Defines the errors that can occur during network operations.
enum JBNetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest
    case unauthorized
    case serverError(statusCode: Int)
    case decodingError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "The response from the server was invalid."
        case .badRequest:
            return "The request was unacceptable, often due to missing a required parameter."
        case .unauthorized:
            return "Unauthorized access. Please check your credentials."
        case .serverError(let statusCode):
            return "The server encountered an error and returned status code: \(statusCode)."
        case .decodingError:
            return "Failed to decode the response from the server."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

/// A protocol defining the core networking capabilities.
/// This conforms to the Dependency Inversion Principle (SOLID), allowing services
/// to depend on this abstraction rather than a concrete implementation, making it easy to mock for unit tests.
protocol JBNetworkManagerProtocol {
    /// Fetches data from the provided URL and decodes it into the specified generic type.
    /// - Parameter url: The URL to fetch data from.
    /// - Returns: The decoded response of type `T`.
    func fetch<T: Decodable>(from url: URL) async throws -> T
}

/// The concrete implementation of the network manager.
final class JBNetworkManager: JBNetworkManagerProtocol {
    
    // Injecting URLSession allows for easier testing/mocking if needed.
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let request = URLRequest(url: url)
        // Default URLRequest is a GET request.
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw JBNetworkError.unknown(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw JBNetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw JBNetworkError.decodingError
            }
        case 400:
            throw JBNetworkError.badRequest
        case 401:
            throw JBNetworkError.unauthorized
        default:
            throw JBNetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
