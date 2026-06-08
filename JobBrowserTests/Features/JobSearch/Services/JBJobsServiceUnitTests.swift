//
//  JBJobsServiceUnitTests.swift
//  JobBrowserTests
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Testing
import Foundation
@testable import JobBrowser

struct JBJobsServiceUnitTests {
    
    @Test func testGetJobDetailsSuccess() async throws {
        let mockNetworkManager = MockNetworkManager()
        
        let mockJob = JBJobModel(
            id: "123",
            postedAt: "2026-06-01",
            jobTitle: "iOS Developer",
            jobDetails: JBJobModel.JobDetails(description: "Great job", location: "Cupertino", salaryRange: "$150k - $200k"),
            companyName: "Apple",
            companyDetails: JBJobModel.CompanyDetails(id: "c1", logo: "apple.png", description: "Tech", website: "apple.com", location: "Cupertino")
        )
        mockNetworkManager.mockData = mockJob
        
        let service = await JBJobsService(networkManager: mockNetworkManager)
        
        let fetchedJob = try await service.getJobDetails(id: "123")
        
        #expect(fetchedJob.id == "123")
        #expect(fetchedJob.jobTitle == "iOS Developer")
        #expect(fetchedJob.companyName == "Apple")
        #expect(mockNetworkManager.capturedURL?.absoluteString.contains("/jobs/123") == true)
    }

    @Test func testGetJobDetailsFailure() async throws {
        let mockNetworkManager = MockNetworkManager()
        mockNetworkManager.shouldReturnError = true
        mockNetworkManager.customError = JBNetworkError.badRequest
        
        let service = await JBJobsService(networkManager: mockNetworkManager)
        
        await #expect(throws: JBNetworkError.badRequest) {
            _ = try await service.getJobDetails(id: "123")
        }
        #expect(mockNetworkManager.capturedURL?.absoluteString.contains("/jobs/123") == true)
    }
}
