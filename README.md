# JobBrowser

JobBrowser is an iOS application designed to search, browse, and view job listings. It leverages modern iOS development practices, utilizing SwiftUI for the user interface and Swift Concurrency for network operations.

## Setup Instructions

1. **Prerequisites**:
   - Xcode 26.0 or later (required for `.xcstrings` String Catalog localization support).
   - iOS 17.0+ Simulator or physical device.

2. **Installation**:
   - Clone this repository to your local machine.
   - Navigate to the project directory: `cd JobBrowser`
   - Open the Xcode project: `open JobBrowser.xcodeproj`

3. **Building and Running**:
   - Select the **JobBrowser** scheme in Xcode.
   - Choose your preferred iOS Simulator or connected device.
   - Press `Cmd + R` (or click the Play button) to build and run the app.

4. **Running Tests**:
   - The project includes both Unit Tests and UI Tests to ensure robustness.
   - Press `Cmd + U` to execute the test suites (ensure a simulator is selected as the destination).

## Architecture Explanation

The application follows the **MVVM** architecture pattern to ensure separation of concerns, high scalability, and robust testability.

- **Model**: Represents the domain data (e.g., `JBJobModel`). Models are purely data structures mapped from network responses.
- **View**: Built entirely with **SwiftUI**. Views are declarative and react directly to state changes published by their corresponding ViewModels.
- **ViewModel**: Encapsulates presentation logic and state management. ViewModels (e.g., `JBJobsListViewModel`) communicate with data services and publish state updates to the Views. They remain independent of `SwiftUI` views, making them highly testable.
- **Services & Networking**: 
  - The `JBNetworkManager` provides a generic, reusable, and concurrency-ready layer for handling HTTP requests.
  - Feature-specific services like `JBJobsService` (which conforms to `JBJobsServiceProtocol`) consume the network manager to fetch domain-specific data. This protocol-oriented approach makes it easy to inject mock implementations (like `MockJBJobsService`) for testing.
  - **Unit Test Coverage**: Total unit tests coverage is 73% 

## Assumptions Made

- **Native Frameworks**: The project relies strictly on first-party Apple frameworks (SwiftUI, Foundation, URLSession). It does not assume or require the installation of third-party dependencies via CocoaPods or Swift Package Manager.
- **Modern iOS Environment**: Given the usage of String Catalogs (`.xcstrings`) and modern architectural patterns, it is assumed the deployment target is iOS 17.0 or newer.
- **API Availability**: It is assumed that the remote https://mockapi.io/ API endpoint serving the job listings is stable and consistently returns JSON structures matching the `JBJobModel`.
- **Mocking Strategy**: A local JSON file (`job-listings.json`) and mock services (`MockJBJobsService`) are utilized in the test target. It is assumed these accurately reflect the production schema to provide reliable, deterministic offline testing.
- **Localization**: English is implemented as the base language, with Apple's modern String Catalogs (`.xcstrings`) set up to facilitate seamless future localization expansions.

## Known Issue
- **No Search Results State Message**: MockAPI returns a 404 error instead of an empty set when no search results are found. So app will display it 404 error instead of no results found.

## Demo
<video src="https://github.com/user-attachments/assets/fb0e69c1-6605-471a-a008-306dff342b24" width="600" controls></video>
