//
//  JBJobsListView.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 07/06/26.
//

import SwiftUI

struct JBJobsListView: View {
    @StateObject private var viewModel = JBJobsListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.jobs.isEmpty {
                    ProgressView("Loading Jobs...")
                } else if let error = viewModel.errorMessage, viewModel.jobs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Failed to load jobs")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchJobs()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                    .padding()
                } else {
                    List(viewModel.jobs) { job in
                        // Display "No results" message if search is active and no jobs are found
                        if viewModel.shouldShowNoResults {
                            Text("No job listings found for \"\(viewModel.searchQuery)\".")
                                .foregroundColor(.secondary)
                                .padding()
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                        
                        // Job cards
                        JBJobCardView(job: job)
                            .background(
                                NavigationLink(destination: JBJobDetailsView(jobId: job.id)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchJobs(searchKeyword: viewModel.searchQuery)
                    }
                }
            }
            .navigationTitle("Job Listings")
            .searchable(text: $viewModel.searchQuery, prompt: "Search jobs")
            .task {
                if viewModel.jobs.isEmpty {
                    await viewModel.fetchJobs()
                }
            }
        }
    }
}

#Preview {
    JBJobsListView()
}
