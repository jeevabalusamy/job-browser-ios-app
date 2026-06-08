//
//  JBLocalization.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Foundation

enum JBLocalization: String {
    case title = "app.name"
    case loadingJobs = "loading.jobs"
    case failedLoadJobs = "failed.load.jobs"
    case retry = "retry"
    case noJobListingsFound = "no.job.listings.found"
    case jobListings = "job.listings"
    case searchJobs = "search.jobs"
    case helloWorld = "hello.world"
    case unknownTitle = "unknown.title"
    case unknownCompany = "unknown.company"
    case unexpectedError = "unexpected.error"
    case failedLoadDetails = "failed.load.details"
    case ok = "ok"
    case aboutThisJob = "about.this.job"
    case companyInformation = "company.information"
    case visitWebsite = "visit.website"
    
    var value: String {
        NSLocalizedString(rawValue, tableName: "Localizable", bundle: .main, value: rawValue, comment: "")
    }

    func value(count: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString(rawValue, tableName: "Localizable", bundle: .main, value: rawValue, comment: ""),
            count
        )
    }
    
    func value(args: CVarArg...) -> String {
        String(format: NSLocalizedString(rawValue, tableName: "Localizable", bundle: .main, value: rawValue, comment: ""), arguments: args)
    }
}
