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
        XCTAssertNil(sut.storage)
    }
    
    func testInitFromSequence() {
        let sequence = AnySequence(1...10)
        sut = Deque(sequence)
        
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.count, (1...10).count)
        XCTAssertNotNil(sut.first)
        XCTAssertNotNil(sut.last)
        XCTAssertEqual(Array(sut), Array(1...10))
        
        sut = Deque(AnySequence<Int>([]))
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)
        XCTAssertNil(sut.first)
        XCTAssertNil(sut.last)
        XCTAssertEqual(Array(sut), [])
    }
    
    func testInitFromCollection() {
        let collection = AnyCollection(1...10)
        sut = Deque(collection)
        
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.count, collection.count)
        XCTAssertNotNil(sut.first)
        XCTAssertNotNil(sut.last)
        XCTAssertEqual(sut.map { $0 }, Array(collection))
        
        sut = Deque(AnyCollection<Int>([]))
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)
        XCTAssertNil(sut.first)
        XCTAssertNil(sut.last)
        XCTAssertEqual(Array(sut), [])
    }
    
    func testInitFromArrayLiteral() {
        sut = [1, 2, 3, 4, 5]
        XCTAssertNotNil(sut)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5])
        
        sut = []
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.isEmpty)
    }
    
    func testInitRepeatingCount() {
        sut = Deque<Int>(repeating: 1, count: 0)
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.isEmpty)
        
        sut = Deque(repeating: 10, count: 10)
        XCTAssertNotNil(sut)
        XCTAssertEqual(Array(sut), Array(repeating: 10, count: 10))
    }
    
    // MARK: - count, isEmpty, first and last properties tests
    func testCount() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.count, sut.storage?.count ?? 0)
        
        sut = Deque([1, 2, 3, 4])
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.count, 4)
        XCTAssertEqual(sut.count, sut.storage?.count ?? 0)
    }
    
    func testIsEmpty() {
        XCTAssertEqual(sut.count, 0)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        XCTAssertEqual(sut.isEmpty, sut.storage?.isEmpty ?? true)
        
        sut.append(1)
        XCTAssertGreaterThan(sut.count, 0)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertNotNil(sut.storage)
        XCTAssertEqual(sut.isEmpty, sut.storage?.isEmpty ?? true)
    }
    
    func testFirst() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.first)
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.first, sut.last)
        
        sut = Deque([1])
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut.first, sut.last)
        
        sut = Deque([1, 2, 3])
        XCTAssertEqual(sut.first, 1)
        XCTAssertGreaterThan(sut.count, 1)
        XCTAssertNotEqual(sut.first, sut.last)
    }
    
    func testLast() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.first)
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.first, sut.last)
        
        sut = Deque([1])
        XCTAssertEqual(sut.last, 1)
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut.first, sut.last)
        
        sut = Deque([1, 2, 3])
        XCTAssertEqual(sut.last, 3)
        XCTAssertGreaterThan(sut.count, 1)
        XCTAssertNotEqual(sut.first, sut.last)
    }
    
    // MARK: - enqueue(_:) and enqueue(contentsOf:) tests
    func testEnqueueElement() {
        var prevCount = sut.count
        sut.enqueue(1)
        XCTAssertEqual(sut.count, prevCount + 1)
        XCTAssertEqual(sut.last, 1)
        
        prevCount = sut.count
        sut.enqueue(2)
        XCTAssertEqual(sut.count, prevCount + 1)
        XCTAssertEqual(sut.last, 2)
        
        // value semantics:
        prevCount = sut.count
        var copy = sut!
        copy.enqueue(3)
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.last, 2)
        XCTAssertEqual(copy.count, prevCount + 1)
        XCTAssertEqual(copy.last, 3)
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testEnqueueSequence() {
        var prevCount = sut.count
        sut.enqueue(contentsOf: [1, 2, 3, 4, 5])
        XCTAssertEqual(sut.count, prevCount + 5)
        XCTAssertEqual(sut.last, 5)
        
        // value semantics:
        prevCount = sut.count
        var copy = sut!
        copy.enqueue(contentsOf: [6, 7, 8, 9, 10])
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.last, 5)
        XCTAssertEqual(copy.count, prevCount + 5)
        XCTAssertEqual(copy.last, 10)
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    
    // MARK: - dequeue() and dequeue(_ k)
    func testDequeueElement() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.dequeue())
        
        sut.enqueue(1)
        var prevFirst = sut.first
        var prevCount = sut.count
        XCTAssertEqual(sut.dequeue(), prevFirst)
        XCTAssertEqual(sut.count, prevCount - 1)
        XCTAssertNotEqual(sut.first, prevFirst)
        
        sut.enqueue(contentsOf: [1, 2, 3, 4, 5])
        prevFirst = sut.first
        prevCount = sut.count
        XCTAssertEqual(sut.dequeue(), prevFirst)
        XCTAssertEqual(sut.count, prevCount - 1)
        XCTAssertNotEqual(sut.first, prevFirst)
        XCTAssertEqual(Array(sut), [2, 3, 4, 5])
        
        // value semantics:
        prevFirst = sut.first
        prevCount = sut.count
        var copy = sut!
        XCTAssertEqual(copy.dequeue(), prevFirst)
        XCTAssertEqual(sut.first, prevFirst)
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(copy.count, prevCount - 1)
        XCTAssertNotEqual(copy.first, sut.first)
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testDequeueElements() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.dequeue(0), [])
        
        sut = [1, 2, 3, 4, 5, 6, 7 ,8, 9, 10]
        var previousCount = sut.count
        var previousElements = Array(sut)
        XCTAssertEqual(sut.dequeue(3), Array(previousElements[0..<3]))
        XCTAssertEqual(Array(sut), Array(previousElements[3..<previousElements.endIndex]))
        XCTAssertEqual(sut.count, previousCount - 3)
        
        // value semantics:
        previousCount = sut.count
        previousElements = Array(sut)
        var copy = sut!
        XCTAssertEqual(copy.dequeue(3), Array(previousElements[0..<3]))
        XCTAssertEqual(sut.count, previousCount)
        XCTAssertEqual(Array(sut), previousElements)
        XCTAssertEqual(copy.count, previousCount - 3)
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    // MARK: - DequeSlice tests
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
