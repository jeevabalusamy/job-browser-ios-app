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
                    ProgressView(JBLocalization.loadingJobs.value)
                } else if let error = viewModel.errorMessage, viewModel.jobs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: JBSystemImage.warning.name)
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(JBLocalization.failedLoadJobs.value)
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button(JBLocalization.retry.value) {
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
                            Text(JBLocalization.noJobListingsFound.value(args: viewModel.searchQuery))
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
            .navigationTitle(JBLocalization.jobListings.value)
            .searchable(text: $viewModel.searchQuery, prompt: Text(JBLocalization.searchJobs.value))
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
