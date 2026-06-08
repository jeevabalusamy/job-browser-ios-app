//
//  JBJobsListView.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 07/06/26.
//

import SwiftUI

struct JBJobsListView: View {
    @StateObject private var viewModel = JBJobsListViewModel()
    
    private struct LayoutConstants {
        static let errorVStackSpacing: CGFloat = 12
        static let retryButtonTopPadding: CGFloat = 8
        static let listRowInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        static let navigationLinkOpacity: Double = 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isInitialLoading {
                    ProgressView(JBLocalization.loadingJobs.value)
                } else if viewModel.showError {
                    VStack(spacing: LayoutConstants.errorVStackSpacing) {
                        Image(systemName: JBSystemImage.warning.name)
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(JBLocalization.failedLoadJobs.value)
                            .font(.headline)
                        Text(viewModel.errorMessage ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button(JBLocalization.retry.value) {
                            Task {
                                await viewModel.fetchJobs()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, LayoutConstants.retryButtonTopPadding)
                    }
                    .padding()
                } else {
                    List {
                        // Display "No results" message if search is active and no jobs are found
                        if viewModel.shouldShowNoResults {
                            Text(viewModel.noResultsMessage)
                                .foregroundColor(.secondary)
                                .padding()
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                        
                        ForEach(viewModel.jobs) { job in
                            // Job cards
                            JBJobCardView(job: job)
                                .background(
                                    NavigationLink(destination: JBJobDetailsView(jobId: job.id)) {
                                        EmptyView()
                                    }
                                    .opacity(LayoutConstants.navigationLinkOpacity)
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(LayoutConstants.listRowInsets)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.refreshJobs()
                    }
                }
            }
            .navigationTitle(JBLocalization.jobListings.value)
            .searchable(text: $viewModel.searchQuery, prompt: Text(JBLocalization.searchJobs.value))
            .task {
                await viewModel.loadJobsIfNeeded()
            }
        }
    }
}

#Preview {
    JBJobsListView()
}
