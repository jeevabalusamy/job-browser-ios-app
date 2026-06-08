//
//  JBURLBuilderUnitTests.swift
//  JobBrowserTests
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Testing
import Foundation
@testable import JobBrowser

struct JBURLBuilderUnitTests {

    @Test("Default initialization sets scheme to https and correct host")
    func testDefaultInitialization() throws {
        let builder = JBURLBuilder()
        let url = try builder.build()
        #expect(url.scheme == "https")
        #expect(url.host == JBEnvironment.current.host)
    }

    @Test("Setting scheme updates the URL scheme")
    func testSetScheme() throws {
        let url = try JBURLBuilder().set(scheme: .http).build()
        #expect(url.scheme == "http")
    }

    @Test("Setting environment updates the URL host")
    func testSetEnvironment() throws {
        let url = try JBURLBuilder().set(environment: .staging).build()
        #expect(url.host == JBEnvironment.staging.host)
    }

    @Test("Setting path adds the path correctly with or without leading slash")
    func testSetPath() throws {
        let urlWithSlash = try JBURLBuilder().set(path: "/api/v1/jobs").build()
        #expect(urlWithSlash.path == "/api/v1/jobs")
        
        let urlWithoutSlash = try JBURLBuilder().set(path: "api/v1/jobs").build()
        #expect(urlWithoutSlash.path == "/api/v1/jobs")
    }

    @Test("Adding a query item appends it to the URL")
    func testAddQueryItem() throws {
        let url = try JBURLBuilder()
            .set(path: "/jobs")
            .addQueryItem(name: "search", value: "developer")
            .addQueryItem(name: "page", value: "1")
            .build()
        
        #expect(url.query?.contains("search=developer") == true)
        #expect(url.query?.contains("page=1") == true)
    }

    @Test("Setting multiple query items replaces existing items")
    func testSetQueryItems() throws {
        let url = try JBURLBuilder()
            .addQueryItem(name: "old", value: "value")
            .setQueryItems(["new1": "val1", "new2": "val2"])
            .build()
        
        #expect(url.query?.contains("old=value") == false)
        #expect(url.query?.contains("new1=val1") == true)
        #expect(url.query?.contains("new2=val2") == true)
    }
}
