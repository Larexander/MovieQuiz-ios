//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by  Александр  on 12.02.2023.
//


import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 20]
        // Then
        XCTAssertNil(value)
    }
    
}
