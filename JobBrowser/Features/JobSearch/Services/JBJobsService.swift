//
//  JBJobsAPIService.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 07/06/26.
//

struct JBJobsService: JBJobsServiceProtocol {
    
    private let networkManager: JBNetworkManagerProtocol
    
    init(networkManager: JBNetworkManagerProtocol = JBNetworkManager()) {
        self.networkManager = networkManager
    }
    
    /// API Paths specific to Job services
    enum Path: String {
        case jobs = "/jobs"
    }
    
    func getJobsListings(searchKeyword: String? = nil) async throws -> [JBJobModel] {
        var urlBuilder = JBURLBuilder()
            .set(path: Path.jobs.rawValue)
        
        if let searchKeyword = searchKeyword, !searchKeyword.isEmpty {
            urlBuilder = urlBuilder.addQueryItem(name: "search", value: searchKeyword)
        }
        let url = try urlBuilder.build()
        
        return try await networkManager.fetch(from: url)
    }
}
