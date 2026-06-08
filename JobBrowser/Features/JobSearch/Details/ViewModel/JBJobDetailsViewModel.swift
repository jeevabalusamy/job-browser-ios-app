//
//  JBJobDetailsViewModel.swift
//  JobBrowser
//

import Combine
import Foundation

final class JBJobDetailsViewModel: ObservableObject {
    @Published var job: JBJobModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let jobsService: JBJobsServiceProtocol
    private let jobId: String
    
    init(jobId: String, jobsService: JBJobsServiceProtocol = JBJobsService()) {
        self.jobId = jobId
        self.jobsService = jobsService
    }
    
    var jobTitle: String {
        job?.jobTitle ?? JBLocalization.unknownTitle.value
    }
    
    var companyName: String {
        job?.companyName ?? JBLocalization.unknownCompany.value
    }
    
    var location: String? {
        job?.jobDetails?.location ?? job?.companyDetails?.location
    }
    
    var salaryRange: String? {
        job?.jobDetails?.salaryRange
    }
    
    var jobDescription: String? {
        job?.jobDetails?.description
    }
    
    var companyDescription: String? {
        job?.companyDetails?.description
    }
    
    var companyLogoURL: URL? {
        guard let logoString = job?.companyDetails?.logo else { return nil }
        return URL(string: logoString)
    }
    
    var companyWebsiteURL: URL? {
        guard let website = job?.companyDetails?.website else { return nil }
        return URL(string: website)
    }
    
    @MainActor
    func fetchJobDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.job = try await jobsService.getJobDetails(id: jobId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
