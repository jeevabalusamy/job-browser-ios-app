//
//  JBJobsListViewModel.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 07/06/26.
//

import Foundation
import Combine

@MainActor
final class JBJobsListViewModel: ObservableObject {
    @Published var jobs: [JBJobModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let service: JBJobsServiceProtocol
    
    init(service: JBJobsServiceProtocol? = nil) {
        self.service = service ?? JBJobsService()
    }
    
    func fetchJobs() async {
        isLoading = true
        errorMessage = nil
        do {
            jobs = try await service.getJobsListings()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
