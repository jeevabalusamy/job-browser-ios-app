//
//  JBJobsListViewModelUnitTests.swift
//  JobBrowserTests
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Testing
import Combine
import Foundation
@testable import JobBrowser

@MainActor
struct JBJobsListViewModelUnitTests {

    @Test func testInitialState() {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        #expect(viewModel.jobs.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.searchQuery == "")
    }

    @Test func testFetchJobsSuccess() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        await viewModel.fetchJobs()
        
        #expect(viewModel.jobs.count == 5)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func testFetchJobsWithSearchKeyword() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        await viewModel.fetchJobs(searchKeyword: "Frontend")
        
        #expect(viewModel.jobs.count == 1)
        #expect(viewModel.jobs.first?.jobTitle == "Frontend Engineer")
    }

    @Test func testFetchJobsFailure() async throws {
        let mockService = MockJBJobsService()
        mockService.shouldReturnError = true
        let viewModel = JBJobsListViewModel(service: mockService)
        
        await viewModel.fetchJobs()
        
        #expect(viewModel.jobs.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test func testSearchQueryDebounce() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        viewModel.searchQuery = "Backend"
        
        // Wait for debounce (500ms) + buffer
        try await Task.sleep(nanoseconds: 600_000_000)
        
        #expect(viewModel.jobs.count == 1)
        #expect(viewModel.jobs.first?.jobTitle == "Backend Engineer")
    }
    
    @Test func testFetchJobsWithEmptySearchKeyword() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        await viewModel.fetchJobs(searchKeyword: "")
        
        // Empty keyword should return all jobs
        #expect(viewModel.jobs.count == 5)
    }

    @Test func testSearchQueryDebounceRemovesDuplicates() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        viewModel.searchQuery = "Backend"
        viewModel.searchQuery = "Backend"
        
        // Wait for debounce (500ms) + buffer
        try await Task.sleep(nanoseconds: 600_000_000)
        
        #expect(viewModel.jobs.count == 1)
        #expect(viewModel.jobs.first?.jobTitle == "Backend Engineer")
    }

    @Test func testFetchJobsWithCaseInsensitiveSearchKeyword() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        await viewModel.fetchJobs(searchKeyword: "fRoNtEnD")
        
        #expect(viewModel.jobs.count == 1)
        #expect(viewModel.jobs.first?.jobTitle == "Frontend Engineer")
    }
    
    @Test func testLoadJobsIfNeeded() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        await viewModel.loadJobsIfNeeded()
        #expect(viewModel.jobs.count == 5)
        
        // Load again shouldn't do anything new
        await viewModel.loadJobsIfNeeded()
        #expect(viewModel.jobs.count == 5)
    }
    
    @Test func testRefreshJobs() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        viewModel.searchQuery = "Data"
        await viewModel.refreshJobs()
        
        #expect(viewModel.jobs.count == 1)
        #expect(viewModel.jobs.first?.jobTitle == "Data Scientist")
    }
    
    @Test func testComputedProperties() async throws {
        let mockService = MockJBJobsService()
        let viewModel = JBJobsListViewModel(service: mockService)
        
        #expect(viewModel.isInitialLoading == false)
        #expect(viewModel.showError == false)
        #expect(viewModel.shouldShowNoResults == false)
        
        // Setup empty state with query
        await viewModel.fetchJobs(searchKeyword: "NonExistentJob")
        viewModel.searchQuery = "NonExistentJob"
        #expect(viewModel.shouldShowNoResults == true)
        #expect(viewModel.isInitialLoading == false)
        
        // Setup error state
        mockService.shouldReturnError = true
        await viewModel.fetchJobs()
        #expect(viewModel.showError == true)
    }
}
