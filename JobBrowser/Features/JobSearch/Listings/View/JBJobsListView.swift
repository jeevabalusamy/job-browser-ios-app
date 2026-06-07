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
        NavigationView {
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
                        JobCardView(job: job)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchJobs()
                    }
                }
            }
            .navigationTitle("Job Listings")
            .task {
                if viewModel.jobs.isEmpty {
                    await viewModel.fetchJobs()
                }
            }
        }
    }
}

struct JobCardView: View {
    let job: JBJobModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Company Logo
            logoView
            
            // Job Details
            VStack(alignment: .leading, spacing: 6) {
                Text(job.jobTitle ?? "Unknown Title")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(job.companyName ?? "Unknown Company")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    if let location = job.jobDetails?.location {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if let salary = job.jobDetails?.salaryRange {
                    HStack(spacing: 4) {
                        Image(systemName: "banknote")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text(salary)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private var logoView: some View {
        if let logoString = job.companyDetails?.logo, let url = URL(string: logoString) {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 50, height: 50)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                case .failure:
                    placeholderLogo
                @unknown default:
                    placeholderLogo
                }
            }
        } else {
            placeholderLogo
        }
    }
    
    private var placeholderLogo: some View {
        Image(systemName: "building.2.crop.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .foregroundColor(.gray)
    }
}

#Preview {
    JBJobsListView()
}
