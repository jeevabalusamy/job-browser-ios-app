//
//  MockJBJobsService.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Foundation
@testable import JobBrowser

class MockJBJobsService: JBJobsServiceProtocol {
    var shouldReturnError = false
    var customError: Error?
    
    private var jsonURL: URL {
        let currentFileURL = URL(fileURLWithPath: #file)
        let directoryURL = currentFileURL.deletingLastPathComponent()
        return directoryURL.appendingPathComponent("job-listings.json")
    }
    
    private func getJobsListFromJson() throws -> [JBJobModel] {
        let data = try Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        let jobs = try decoder.decode([JBJobModel].self, from: data)
        return jobs
    }
    
    func getJobsListings(searchKeyword: String?) async throws -> [JBJobModel] {
        if shouldReturnError {
            throw customError ?? URLError(.badServerResponse)
        }
        
        let jobs = try getJobsListFromJson()
        
        if let keyword = searchKeyword, !keyword.isEmpty {
            return jobs.filter { job in
                let titleMatch = job.jobTitle?.localizedCaseInsensitiveContains(keyword) ?? false
                let companyMatch = job.companyName?.localizedCaseInsensitiveContains(keyword) ?? false
                return titleMatch || companyMatch
            }
        }
        
        return jobs
    }
    
    func getJobDetails(id: String) async throws -> JBJobModel {
        if shouldReturnError {
            throw customError ?? URLError(.badServerResponse)
        }
        
        let jobs = try getJobsListFromJson()
        
        guard let job = jobs.first(where: { $0.id == id }) else {
            throw URLError(.resourceUnavailable)
        }
        
        return job
    }
}
