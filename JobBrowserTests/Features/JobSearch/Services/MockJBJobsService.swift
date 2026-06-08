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
    
    func getJobsListings(searchKeyword: String?) async throws -> [JBJobModel] {
        if shouldReturnError {
            throw customError ?? URLError(.badServerResponse)
        }
        
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "job-listings", withExtension: "json") else {
            fatalError("Failed to locate job-listings.json in bundle.")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jobs = try decoder.decode([JBJobModel].self, from: data)
        
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
        
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "job-listings", withExtension: "json") else {
            fatalError("Failed to locate job-listings.json in bundle.")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jobs = try decoder.decode([JBJobModel].self, from: data)
        
        guard let job = jobs.first(where: { $0.id == id }) else {
            throw URLError(.resourceUnavailable)
        }
        
        return job
    }
}
