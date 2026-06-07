//
//  JBJobsListViewModel.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 07/06/26.
//

import Foundation
import Combine

class JBJobsListViewModel: ObservableObject {
    @Published var jobs: [JBJobModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    
    private let service: JBJobsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(service: JBJobsServiceProtocol = JBJobsService()) {
        self.service = service
        setupSearchDebounce()
    }
    
    /// Sets up debouncing for the search query.
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                Task {
                    await self.fetchJobs(searchKeyword: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Fetches job listings, optionally with a search keyword.
    @MainActor
    func fetchJobs(searchKeyword: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedJobs = try await service.getJobsListings(searchKeyword: searchKeyword)
            self.jobs = fetchedJobs
        } catch {
            if let networkError = error as? JBNetworkError {
                self.errorMessage = networkError.localizedDescription
            } else {
                self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
            self.jobs = [] // Clear jobs on error
        }
        isLoading = false
    }
    
    /// Checks if a "no results" message should be displayed.
    var shouldShowNoResults: Bool {
        !isLoading && jobs.isEmpty && !searchQuery.isEmpty && errorMessage == nil
    }
}