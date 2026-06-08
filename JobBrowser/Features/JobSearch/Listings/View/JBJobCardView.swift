//
//  JBJobCardView.swift
//  JobBrowser
//

import SwiftUI

struct JBJobCardView: View {
    @StateObject private var viewModel: JBJobCardViewModel
    
    private struct LayoutConstants {
        static let hStackSpacing: CGFloat = 16
        static let vStackSpacing: CGFloat = 6
        static let iconSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 5
        static let shadowY: CGFloat = 2
        static let shadowOpacity: Double = 0.08
        static let logoSize: CGFloat = 50
        static let logoCornerRadius: CGFloat = 8
        static let titleLineLimit: Int = 2
        static let defaultLineLimit: Int = 1
        static let minSpacerLength: CGFloat = 0
    }
    
    init(job: JBJobModel) {
        _viewModel = StateObject(wrappedValue: JBJobCardViewModel(job: job))
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: LayoutConstants.hStackSpacing) {
            // Company Logo
            logoView
            
            // Job Details
            VStack(alignment: .leading, spacing: LayoutConstants.vStackSpacing) {
                Text(viewModel.jobTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(LayoutConstants.titleLineLimit)
                
                Text(viewModel.companyName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(LayoutConstants.defaultLineLimit)
                
                HStack(spacing: LayoutConstants.iconSpacing) {
                    if let location = viewModel.location {
                        Image(systemName: JBSystemImage.location.name)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(LayoutConstants.defaultLineLimit)
                    }
                }
                
                if let salary = viewModel.salaryRange {
                    HStack(spacing: LayoutConstants.iconSpacing) {
                        Image(systemName: JBSystemImage.salary.name)
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text(salary)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .lineLimit(LayoutConstants.defaultLineLimit)
                    }
                }
            }
            
            Spacer(minLength: LayoutConstants.minSpacerLength)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(LayoutConstants.shadowOpacity), radius: LayoutConstants.shadowRadius, x: 0, y: LayoutConstants.shadowY)
        )
    }
    
    @ViewBuilder
    private var logoView: some View {
        if let url = viewModel.companyLogoURL {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: LayoutConstants.logoSize, height: LayoutConstants.logoSize)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: LayoutConstants.logoSize, height: LayoutConstants.logoSize)
                        .cornerRadius(LayoutConstants.logoCornerRadius)
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
            .frame(width: LayoutConstants.logoSize, height: LayoutConstants.logoSize)
            .foregroundColor(.gray)
    }
}
