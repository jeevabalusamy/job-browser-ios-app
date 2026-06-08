//
//  MockNetworkManager.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Foundation
@testable import JobBrowser

class MockNetworkManager: JBNetworkManagerProtocol {
    var shouldReturnError = false
    var mockData: Any?
    var customError: Error?
    var capturedURL: URL?
    
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        self.capturedURL = url
        if shouldReturnError {
            throw customError ?? JBNetworkError.invalidResponse
        }
        
        if let mockData = mockData as? T {
            return mockData
        }
        
        throw JBNetworkError.decodingError
    }
}
