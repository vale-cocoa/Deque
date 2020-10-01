import XCTest
@testable import Deque

final class DequeTests: XCTestCase {
    var sut: Deque<Int>!
    
    override func setUp() {
        super.setUp()
        
        sut = Deque<Int>()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    // MARK: - Slices tests
    func testSlice_withContiguousStorageIfAvailable() {
        sut.append(contentsOf: [1, 2, 3, 4, 5])
        
        var dequeSlice = sut[1..<5]
        
        XCTAssertEqual(dequeSlice.count, 4)
        
        XCTAssertNotNil(dequeSlice
            .withContiguousMutableStorageIfAvailable { buff in
                // In here subscripting the buffer is 0 based!
                buff[0] = 10
            }
        )
        XCTAssertEqual(dequeSlice[1], 10)
        XCTAssertEqual(sut[1], 2)
    }
    
}
