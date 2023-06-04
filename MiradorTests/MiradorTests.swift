//
//  MiradorTests.swift
//  MiradorTests
//
//  Created by Aled Samuel on 04/06/2023.
//

import XCTest
import Mirador

final class MiradorTests: XCTestCase {

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testGreenwich2Points() throws {
        
        let data = """
        {
            "anchor": {
                "name": "greenwich",
                "physical_width": 0.5,
                "coordinate": [-0.00084588, 51.47787836],
                "altitude": 46.0,
                "bearing_degrees": -30,
                "orientation": "horizontal"
            },
            "points_of_interest": [
                {
                    "name": "Canary Wharf",
                    "coordinate": [-0.01948017, 51.50493780],
                    "altitude": 235
                },
                {
                    "name": "O2 Arena",
                    "coordinate": [0.00321850, 51.50296112],
                    "altitude": 52
                }
            ],
            "version": "1.0",
        }
        """.data(using: .utf8)!
        
        if let anchor = LocationAnchor.anchorFromJSONData(jsonData: data) {
            XCTAssertEqual(anchor.name, "greenwich")
            XCTAssertEqual(anchor.physicalWidth, 0.5)
            XCTAssertEqual(anchor.pointsOfInterest.count, 2)
            XCTAssertEqual(anchor.orientation, .horizontal)
        } else {
            XCTFail("Expected value for anchor from JSON data.")
        }
    }
}
