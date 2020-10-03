//
//  DequeSliceTests.swift
//  DequeTests
//
//  Created by Valeriano Della Longa on 03/10/2020.
//

import XCTest
import CircularBuffer
@testable import Deque

final class DequeSliceTests: XCTestCase {
    var sut: DequeSlice<Int>!
    
    override func setUp() {
        super.setUp()
        
        sut = DequeSlice<Int>()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - withContiguousStorageIfAvailable and withContiguousMutableStorageIfAvailable tests
    func testWithContiguousStorageIfAvailable() {
        let original: Deque<Int> = [1, 2, 3, 4, 5]
        sut = original[1..<5]
        
        XCTAssertEqual(sut.count, 4)
        
        XCTAssertNotNil(sut
            .withContiguousMutableStorageIfAvailable { buff in
                // In here subscripting the buffer is 0 based!
                buff[0] = 10
            }
        )
        XCTAssertEqual(sut[1], 10)
        XCTAssertEqual(original[1], 2)
    }
    
}
