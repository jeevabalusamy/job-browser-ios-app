//
//  JBNetworkManagerUnitTests.swift
//  JobBrowserTests
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Testing
import Foundation
@testable import JobBrowser

extension JBNetworkError: @retroactive Equatable {
    public static func == (lhs: JBNetworkError, rhs: JBNetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.badRequest, .badRequest),
             (.unauthorized, .unauthorized),
             (.decodingError, .decodingError):
            return true
        case (.serverError(let code1), .serverError(let code2)):
            return code1 == code2
        case (.unknown(let err1), .unknown(let err2)):
            return err1.localizedDescription == err2.localizedDescription
        default:
            return false
        }
    }
}

final class MockURLProtocol: URLProtocol {
    struct MockResponse {
        let response: HTTPURLResponse?
        let data: Data?
        let error: Error?
    }
    
    private static let lock = NSLock()
    private static var mocks: [String: MockResponse] = [:]
    
    static func setMock(for url: URL, response: HTTPURLResponse?, data: Data?, error: Error?) {
        lock.lock()
        defer { lock.unlock() }
        mocks[url.absoluteString] = MockResponse(response: response, data: data, error: error)
    }
    
    static func removeMock(for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        mocks.removeValue(forKey: url.absoluteString)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let urlString = request.url?.absoluteString else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        
        MockURLProtocol.lock.lock()
        let mock = MockURLProtocol.mocks[urlString]
        MockURLProtocol.lock.unlock()
        
        if let error = mock?.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = mock?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = mock?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

struct JBNetworkManagerUnitTests {
    
    struct TestModel: Decodable, Equatable {
        let id: Int
        let name: String
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
    
    @Test("Fetch successfully decodes valid JSON with 200 status code")
    func testFetchSuccess() async throws {
        let url = URL(string: "https://test.com/success")!
        let json = """
        {
            "id": 1,
            "name": "Test Job"
        }
        """.data(using: .utf8)!
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.setMock(for: url, response: response, data: json, error: nil)
        
        let manager = await JBNetworkManager(session: makeSession())
        let result: TestModel = try await manager.fetch(from: url)
        
        #expect(result == TestModel(id: 1, name: "Test Job"))
        MockURLProtocol.removeMock(for: url)
    }
    
    @Test("Fetch throws decodingError when JSON is invalid")
    func testFetchDecodingError() async throws {
        let url = URL(string: "https://test.com/decoding-error")!
        let json = "invalid json".data(using: .utf8)!
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.setMock(for: url, response: response, data: json, error: nil)
        
        let manager = await JBNetworkManager(session: makeSession())
        
        await #expect(throws: JBNetworkError.decodingError) {
            let _: TestModel = try await manager.fetch(from: url)
        }
        MockURLProtocol.removeMock(for: url)
    }
    
    @Test("Fetch throws badRequest for 400 status code")
    func testFetchBadRequest() async throws {
        let url = URL(string: "https://test.com/bad-request")!
        let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        MockURLProtocol.setMock(for: url, response: response, data: Data(), error: nil)
        
        let manager = await JBNetworkManager(session: makeSession())
        
        await #expect(throws: JBNetworkError.badRequest) {
            let _: TestModel = try await manager.fetch(from: url)
        }
        MockURLProtocol.removeMock(for: url)
    }
    
    @Test("Fetch throws unauthorized for 401 status code")
    func testFetchUnauthorized() async throws {
        let url = URL(string: "https://test.com/unauthorized")!
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        MockURLProtocol.setMock(for: url, response: response, data: Data(), error: nil)
        
        let manager = await JBNetworkManager(session: makeSession())
        
        await #expect(throws: JBNetworkError.unauthorized) {
            let _: TestModel = try await manager.fetch(from: url)
        }
        MockURLProtocol.removeMock(for: url)
    }
    
    @Test("Fetch throws serverError for 500 status code")
    func testFetchServerError() async throws {
        let url = URL(string: "https://test.com/server-error")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        MockURLProtocol.setMock(for: url, response: response, data: Data(), error: nil)
        
        let manager = await JBNetworkManager(session: makeSession())
        
        await #expect(throws: JBNetworkError.serverError(statusCode: 500)) {
            let _: TestModel = try await manager.fetch(from: url)
        }
        MockURLProtocol.removeMock(for: url)
    }
    
    @Test("Fetch throws unknown error when network fails")
    func testFetchNetworkFailure() async throws {
        let url = URL(string: "https://test.com/network-error")!
        let networkError = URLError(.notConnectedToInternet)
        MockURLProtocol.setMock(for: url, response: nil, data: nil, error: networkError)
        
        let manager = await JBNetworkManager(session: makeSession())
        
        await #expect(throws: JBNetworkError.unknown(networkError)) {
            let _: TestModel = try await manager.fetch(from: url)
        }
        MockURLProtocol.removeMock(for: url)
    }
    
    @Test("JBNetworkError errorDescription returns expected strings")
    func testErrorDescription() {
        #expect(JBNetworkError.invalidURL.errorDescription == "The URL provided was invalid.")
        #expect(JBNetworkError.invalidResponse.errorDescription == "The response from the server was invalid.")
        #expect(JBNetworkError.badRequest.errorDescription == "The request was unacceptable, often due to missing a required parameter.")
        #expect(JBNetworkError.unauthorized.errorDescription == "Unauthorized access. Please check your credentials.")
        #expect(JBNetworkError.serverError(statusCode: 500).errorDescription == "The server encountered an error and returned status code: 500.")
        #expect(JBNetworkError.decodingError.errorDescription == "Failed to decode the response from the server.")
        
        let testError = URLError(.notConnectedToInternet)
        #expect(JBNetworkError.unknown(testError).errorDescription == "An unknown error occurred: \(testError.localizedDescription)")
    }
}
