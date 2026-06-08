//
//  JBJobCardViewModelUnitTests.swift
//  JobBrowserTests
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Testing
import Foundation
@testable import JobBrowser

@MainActor
struct JBJobCardViewModelUnitTests {

    @Test("Initialization and id mapping")
    func testIdMapping() {
        let job = createMockJob(id: "job-123")
        let viewModel = JBJobCardViewModel(job: job)
        #expect(viewModel.id == "job-123")
    }

    @Test("Job title maps correctly when provided")
    func testJobTitleWhenProvided() {
        let job = createMockJob(jobTitle: "Software Engineer")
        let viewModel = JBJobCardViewModel(job: job)
        #expect(viewModel.jobTitle == "Software Engineer")
    }

    @Test("Job title uses fallback when nil")
    func testJobTitleWhenNil() {
        let job = createMockJob(jobTitle: nil)
        let viewModel = JBJobCardViewModel(job: job)
        #expect(viewModel.jobTitle == JBLocalization.unknownTitle.value)
    }

    @Test("Company name maps correctly when provided")
    func testCompanyNameWhenProvided() {
        let job = createMockJob(companyName: "Tech Corp")
        let viewModel = JBJobCardViewModel(job: job)
        #expect(viewModel.companyName == "Tech Corp")
    }

    @Test("Company name uses fallback when nil")
    func testCompanyNameWhenNil() {
        let job = createMockJob(companyName: nil)
        let viewModel = JBJobCardViewModel(job: job)
        #expect(viewModel.companyName == JBLocalization.unknownCompany.value)
    }

    @Test("Location mapping")
    func testLocation() {
        let jobWithLocation = createMockJob(location: "New York")
        let viewModelWithLocation = JBJobCardViewModel(job: jobWithLocation)
        #expect(viewModelWithLocation.location == "New York")
        #expect(viewModelWithLocation.hasLocation == true)

        let jobWithoutLocation = createMockJob(location: nil)
        let viewModelWithoutLocation = JBJobCardViewModel(job: jobWithoutLocation)
        #expect(viewModelWithoutLocation.location == nil)
        #expect(viewModelWithoutLocation.hasLocation == false)
    }

    @Test("Salary range mapping")
    func testSalaryRange() {
        let jobWithSalary = createMockJob(salaryRange: "$100k - $120k")
        let viewModelWithSalary = JBJobCardViewModel(job: jobWithSalary)
        #expect(viewModelWithSalary.salaryRange == "$100k - $120k")
        #expect(viewModelWithSalary.hasSalaryRange == true)

        let jobWithoutSalary = createMockJob(salaryRange: nil)
        let viewModelWithoutSalary = JBJobCardViewModel(job: jobWithoutSalary)
        #expect(viewModelWithoutSalary.salaryRange == nil)
        #expect(viewModelWithoutSalary.hasSalaryRange == false)
    }

    @Test("Company logo mapping")
    func testCompanyLogo() {
        let jobWithLogo = createMockJob(logo: "https://example.com/logo.png")
        let viewModelWithLogo = JBJobCardViewModel(job: jobWithLogo)
        #expect(viewModelWithLogo.companyLogoURL?.absoluteString == "https://example.com/logo.png")
        #expect(viewModelWithLogo.hasCompanyLogo == true)

        let jobWithoutLogo = createMockJob(logo: nil)
        let viewModelWithoutLogo = JBJobCardViewModel(job: jobWithoutLogo)
        #expect(viewModelWithoutLogo.companyLogoURL == nil)
        #expect(viewModelWithoutLogo.hasCompanyLogo == false)
    }

    // MARK: - Helpers
    private func createMockJob(
        id: String = "1",
        jobTitle: String? = "Test Job",
        companyName: String? = "Test Company",
        location: String? = "Test Location",
        salaryRange: String? = "100k",
        logo: String? = "https://example.com/logo.png"
    ) -> JBJobModel {
        JBJobModel(
            id: id,
            postedAt: "2026-01-01T00:00:00Z",
            jobTitle: jobTitle,
            jobDetails: JBJobModel.JobDetails(
                description: "Test Description",
                location: location,
                salaryRange: salaryRange
            ),
            companyName: companyName,
            companyDetails: JBJobModel.CompanyDetails(
                id: "comp-1",
                logo: logo,
                description: "Company Description",
                website: "https://example.com",
                location: location
            )
        )
    }
}
