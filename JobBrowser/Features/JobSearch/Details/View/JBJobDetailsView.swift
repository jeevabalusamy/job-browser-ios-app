//
//  JBJobDetailsView.swift
//  JobBrowser
//

import SwiftUI

struct JBJobDetailsView: View {
    @StateObject private var viewModel: JBJobDetailsViewModel
    
    init(jobId: String) {
        _viewModel = StateObject(wrappedValue: JBJobDetailsViewModel(jobId: jobId))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    quickInfoView
                    aboutJobView
                    companyInfoView
                }
                .padding()
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchJobDetails()
        }
        .alert("Failed to load details", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 16) {
            if let url = viewModel.companyLogoURL {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 90, height: 90)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 90)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                    case .failure:
                        placeholderLogo
                    @unknown default:
                        placeholderLogo
                    }
                }
            } else {
                placeholderLogo
            }
            
            VStack(spacing: 6) {
                Text(viewModel.jobTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(viewModel.companyName)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 10)
        .frame(maxWidth: .infinity)
    }
    
    private var placeholderLogo: some View {
        Image(systemName: "building.2.crop.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 90, height: 90)
            .foregroundColor(.gray)
    }
    
    @ViewBuilder
    private var quickInfoView: some View {
        if viewModel.location != nil || viewModel.salaryRange != nil {
            VStack(alignment: .leading, spacing: 12) {
                if let location = viewModel.location {
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                if let salary = viewModel.salaryRange {
                    HStack(spacing: 12) {
                        Image(systemName: "banknote")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        Text(salary)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
    }
    
    @ViewBuilder
    private var aboutJobView: some View {
        if let description = viewModel.jobDescription {
            VStack(alignment: .leading, spacing: 12) {
                Text("About this job")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
    }
    
    @ViewBuilder
    private var companyInfoView: some View {
        if viewModel.companyDescription != nil || viewModel.companyWebsiteURL != nil {
            VStack(alignment: .leading, spacing: 12) {
                Text("Company Information")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let compDesc = viewModel.companyDescription {
                    Text(compDesc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if let websiteURL = viewModel.companyWebsiteURL {
                    Link(destination: websiteURL) {
                        HStack {
                            Text("Visit Website")
                            Image(systemName: "arrow.up.right.square")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        JBJobDetailsView(jobId: "1")
    }
}