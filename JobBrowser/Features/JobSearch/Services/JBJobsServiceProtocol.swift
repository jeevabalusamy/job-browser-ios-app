//
//  JBJobsServiceProtocol.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 07/06/26.
//

protocol JBJobsServiceProtocol {
    func getJobsListings(searchKeyword: String?) async throws -> [JBJobModel]
}
