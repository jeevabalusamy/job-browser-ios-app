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
        case jobs = "api/v1/jobs"
    }
    
    func getJobsListings() async throws -> [JBJobModel] {
        let url = try JBURLBuilder()
            .set(path: Path.jobs.rawValue)
            .build()
        
        return try await networkManager.fetch(from: url)
    }
}
