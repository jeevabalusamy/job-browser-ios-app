//
//  JBJobCardViewModel.swift
//  JobBrowser
//

import Combine
import Foundation

@MainActor
final class JBJobCardViewModel: ObservableObject {
    private let job: JBJobModel
    
    init(job: JBJobModel) {
        self.job = job
    }
    
    var id: String {
        job.id
    }
    
    var jobTitle: String {
        job.jobTitle ?? "Unknown Title"
    }
    
    var companyName: String {
        job.companyName ?? "Unknown Company"
    }
    
    var location: String? {
        job.jobDetails?.location
    }
    
    var salaryRange: String? {
        job.jobDetails?.salaryRange
    }
    
    var companyLogoURL: URL? {
        guard let logoString = job.companyDetails?.logo else { return nil }
        return URL(string: logoString)
    }
}
