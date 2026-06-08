//
//  JBJobCardView.swift
//  JobBrowser
//

import SwiftUI

struct JBJobCardView: View {
    @StateObject private var viewModel: JBJobCardViewModel
    
    init(job: JBJobModel) {
        _viewModel = StateObject(wrappedValue: JBJobCardViewModel(job: job))
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Company Logo
            logoView
            
            // Job Details
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.jobTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(viewModel.companyName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    if let location = viewModel.location {
                        Image(systemName: JBSystemImage.location.name)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if let salary = viewModel.salaryRange {
                    HStack(spacing: 4) {
                        Image(systemName: JBSystemImage.salary.name)
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
        if let url = viewModel.companyLogoURL {
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
        Image(systemName: JBSystemImage.building.name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .foregroundColor(.gray)
    }
}
