//
//  JBJobDetailsViewModelUnitTests.swift
//  JobBrowserTests
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Testing
import Foundation
@testable import JobBrowser

@MainActor
struct JBJobDetailsViewModelUnitTests {

    @Test("Initial state before fetching")
    func testInitialState() {
        let mockService = MockJBJobsService()
        let viewModel = JBJobDetailsViewModel(jobId: "1", jobsService: mockService)
        
        #expect(viewModel.job == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showError == false)
        #expect(viewModel.errorMessage == nil)
        
        // Default properties when job is nil
        #expect(viewModel.jobTitle == JBLocalization.unknownTitle.value)
        #expect(viewModel.companyName == JBLocalization.unknownCompany.value)
        #expect(viewModel.location == nil)
        #expect(viewModel.salaryRange == nil)
        #expect(viewModel.jobDescription == nil)
        #expect(viewModel.companyDescription == nil)
        #expect(viewModel.companyLogoURL == nil)
        #expect(viewModel.companyWebsiteURL == nil)
        #expect(viewModel.hasQuickInfo == false)
        #expect(viewModel.hasCompanyInfo == false)
        #expect(viewModel.hasAboutJob == false)
        #expect(viewModel.hasCompanyLogo == false)
    }

    @Test("Fetch job details successfully")
    func testFetchJobDetailsSuccess() async {
        let mockService = MockJBJobsService()
        let viewModel = JBJobDetailsViewModel(jobId: "1", jobsService: mockService)
        
        await viewModel.fetchJobDetails()
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.job != nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showError == false)
        
        // Properties mapping for job ID "1"
        #expect(viewModel.jobTitle == "Frontend Engineer")
        #expect(viewModel.companyName == "Stripe")
        #expect(viewModel.location == "Remote / San Francisco, CA")
        #expect(viewModel.salaryRange == "$140K-$180K")
        #expect(viewModel.jobDescription != nil)
        #expect(viewModel.companyDescription != nil)
        #expect(viewModel.companyLogoURL?.absoluteString == "https://github.com/stripe.png")
        #expect(viewModel.companyWebsiteURL?.absoluteString == "https://stripe.com")
        
        #expect(viewModel.hasQuickInfo == true)
        #expect(viewModel.hasCompanyInfo == true)
        #expect(viewModel.hasAboutJob == true)
        #expect(viewModel.hasCompanyLogo == true)
    }

    @Test("Fetch job details failure")
    func testFetchJobDetailsFailure() async {
        let mockService = MockJBJobsService()
        mockService.shouldReturnError = true
        let viewModel = JBJobDetailsViewModel(jobId: "1", jobsService: mockService)
        
        await viewModel.fetchJobDetails()
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.job == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.showError == true)
    }
    
    @Test("Job location fallback to company location")
    func testLocationFallback() {
        let viewModel = JBJobDetailsViewModel(jobId: "test")
        
        let job = JBJobModel(
            id: "1",
            postedAt: "2026-06-01T10:00:00.000Z",
            jobTitle: "Test",
            jobDetails: JBJobModel.JobDetails(description: nil, location: nil, salaryRange: nil),
            companyName: "Test Company",
            companyDetails: JBJobModel.CompanyDetails(id: "1", logo: nil, description: nil, website: nil, location: "Company Location")
        )
        
        viewModel.job = job
        
        #expect(viewModel.location == "Company Location")
    }

    @Test("Job location preferred over company location")
    func testJobLocationPreferred() {
        let viewModel = JBJobDetailsViewModel(jobId: "test")
        
        let job = JBJobModel(
            id: "1",
            postedAt: "2026-06-01T10:00:00.000Z",
            jobTitle: "Test",
            jobDetails: JBJobModel.JobDetails(description: nil, location: "Job Location", salaryRange: nil),
            companyName: "Test Company",
            companyDetails: JBJobModel.CompanyDetails(id: "1", logo: nil, description: nil, website: nil, location: "Company Location")
        )
        
        viewModel.job = job
        
        #expect(viewModel.location == "Job Location")
    }
    
    @Test("Property booleans are false when nil")
    func testPropertyBooleansWhenNil() {
        let viewModel = JBJobDetailsViewModel(jobId: "test")
        
        let job = JBJobModel(
            id: "1",
            postedAt: "2026-06-01T10:00:00.000Z",
            jobTitle: "Test",
            jobDetails: JBJobModel.JobDetails(description: nil, location: nil, salaryRange: nil),
            companyName: "Test Company",
            companyDetails: JBJobModel.CompanyDetails(id: "1", logo: nil, description: nil, website: nil, location: nil)
        )
        
        viewModel.job = job
        
        #expect(viewModel.hasQuickInfo == false)
        #expect(viewModel.hasCompanyInfo == false)
        #expect(viewModel.hasAboutJob == false)
        #expect(viewModel.hasCompanyLogo == false)
    }
}
