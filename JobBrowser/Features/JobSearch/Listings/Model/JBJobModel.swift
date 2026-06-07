//
//  JBJobModel.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 07/06/26.
//

import Foundation

struct JBJobModel: Codable, Identifiable, Hashable {
    let id: String
    let postedAt: String
    let jobTitle: String?
    let jobDetails: JobDetails?
    let companyName: String?
    let companyDetails: CompanyDetails?
    
    struct JobDetails: Codable, Hashable {
        let description: String?
        let location: String?
        let salaryRange: String?
    }
    
    struct CompanyDetails: Codable, Hashable {
        let id: String?
        let logo: String?
        let description: String?
        let website: String?
        let location: String?
    }
}
