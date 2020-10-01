import XCTest
@testable import Deque
import CircularBuffer

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
    
    // MARK: - Initialize tests
    func testInit() {
        sut = Deque<Int>()
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)
        XCTAssertNil(sut.first)
        XCTAssertNil(sut.last)
    }
    
    func testInitFromSequence() {
        let sequence = AnySequence(1...10)
        sut = Deque(sequence)
        
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.count, (1...10).count)
        XCTAssertNotNil(sut.first)
        XCTAssertNotNil(sut.last)
        XCTAssertEqual(sut.map { $0 }, (1...10).map { $0 })
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
    
    // MARK: - Performance tests
    func testDequePerformance() {
        //measure(performanceLoopDeque)
    }
    
    func testArrayPerformance() {
        //measure(performanceLoopArray)
    }
    
    func testCircularBufferPerformance() {
        //measure(performanceLoopCircularBuffer)
    }
    
    // MARK: - Private helpers
    private func performanceLoopDeque() {
        let outerCount: Int = 10_000
        let innerCount: Int = 20
        var accumulator = 0
        for _ in 1...outerCount {
            var deque = Deque<Int>()
            deque.reserveCapacity(innerCount)
            for i in 1...innerCount {
                deque.append(i)
                accumulator ^= (deque.last ?? 0)
            }
            for _ in 1...innerCount {
                accumulator ^= (deque.first ?? 0)
                deque.popFirst()
            }
        }
        XCTAssert(accumulator == 0)
    }
    
    private func performanceLoopArray() {
        let outerCount: Int = 10_000
        let innerCount: Int = 20
        var accumulator = 0
        for _ in 1...outerCount {
            var array = Array<Int>()
            for i in 1...innerCount {
                array.append(i)
                accumulator ^= (array.last ?? 0)
            }
            for _ in 1...innerCount {
                accumulator ^= (array.first ?? 0)
                array.remove(at: 0)
            }
        }
        XCTAssert(accumulator == 0)
    }
    
    private func performanceLoopCircularBuffer() {
        let outerCount: Int = 10_000
        let innerCount: Int = 20
        var accumulator = 0
        for _ in 1...outerCount {
            let ringBuffer = CircularBuffer<Int>(capacity: innerCount)
            for i in 1...innerCount {
                ringBuffer.append(i)
                accumulator ^= (ringBuffer.last ?? 0)
            }
            for _ in 1...innerCount {
                accumulator ^= (ringBuffer.first ?? 0)
                ringBuffer.popFirst()
            }
        }
        XCTAssert(accumulator == 0)
    }
    
}
