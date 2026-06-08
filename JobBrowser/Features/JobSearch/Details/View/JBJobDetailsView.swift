//
//  JBJobDetailsView.swift
//  JobBrowser
//

import SwiftUI

struct JBJobDetailsView: View {
    @StateObject private var viewModel: JBJobDetailsViewModel
    
    private struct LayoutConstants {
        static let vStackSpacing: CGFloat = 20
        static let progressViewCornerRadius: CGFloat = 8
        static let progressViewOpacity: Double = 0.8
        static let headerVStackSpacing: CGFloat = 16
        static let headerTopPadding: CGFloat = 10
        static let headerVStackInnerSpacing: CGFloat = 6
        static let logoSize: CGFloat = 90
        static let logoCornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 5
        static let shadowY: CGFloat = 2
        static let shadowOpacity: Double = 0.08
        static let cardShadowOpacity: Double = 0.05
        static let infoVStackSpacing: CGFloat = 12
        static let infoHStackSpacing: CGFloat = 12
        static let iconWidth: CGFloat = 20
        static let websiteLinkTopPadding: CGFloat = 4
        static let cardCornerRadius: CGFloat = 12
    }
    
    init(jobId: String) {
        _viewModel = StateObject(wrappedValue: JBJobDetailsViewModel(jobId: jobId))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LayoutConstants.vStackSpacing) {
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
                    .background(Color(.systemBackground).opacity(LayoutConstants.progressViewOpacity))
                    .cornerRadius(LayoutConstants.progressViewCornerRadius)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchJobDetails()
        }
        .alert(JBLocalization.failedLoadDetails.value, isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button(JBLocalization.ok.value, role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: LayoutConstants.headerVStackSpacing) {
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
                            .shadow(color: Color.black.opacity(LayoutConstants.shadowOpacity), radius: LayoutConstants.shadowRadius, x: 0, y: LayoutConstants.shadowY)
                    case .failure:
                        placeholderLogo
                    @unknown default:
                        placeholderLogo
                    }
                }
            } else {
                placeholderLogo
            }
            
            VStack(spacing: LayoutConstants.headerVStackInnerSpacing) {
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
        .padding(.top, LayoutConstants.headerTopPadding)
        .frame(maxWidth: .infinity)
    }
    
    private var placeholderLogo: some View {
        Image(systemName: JBSystemImage.building.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: LayoutConstants.logoSize, height: LayoutConstants.logoSize)
            .foregroundColor(.gray)
    }
    
    @ViewBuilder
    private var quickInfoView: some View {
        if viewModel.location != nil || viewModel.salaryRange != nil {
            VStack(alignment: .leading, spacing: LayoutConstants.infoVStackSpacing) {
                if let location = viewModel.location {
                    HStack(spacing: LayoutConstants.infoHStackSpacing) {
                        Image(systemName: JBSystemImage.location.name)
                            .foregroundColor(.gray)
                            .frame(width: LayoutConstants.iconWidth)
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                if let salary = viewModel.salaryRange {
                    HStack(spacing: LayoutConstants.infoHStackSpacing) {
                        Image(systemName: JBSystemImage.salary.rawValue)
                            .foregroundColor(.green)
                            .frame(width: LayoutConstants.iconWidth)
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
            VStack(alignment: .leading, spacing: LayoutConstants.infoVStackSpacing) {
                Text(JBLocalization.aboutThisJob.value)
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
            VStack(alignment: .leading, spacing: LayoutConstants.infoVStackSpacing) {
                Text(JBLocalization.companyInformation.value)
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
                            Text(JBLocalization.visitWebsite.value)
                            Image(systemName: JBSystemImage.externalLink.name)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, LayoutConstants.websiteLinkTopPadding)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: LayoutConstants.cardCornerRadius)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(LayoutConstants.cardShadowOpacity), radius: LayoutConstants.shadowRadius, x: 0, y: LayoutConstants.shadowY)
    }
}

#Preview {
    NavigationStack {
        JBJobDetailsView(jobId: "1")
    }
}
