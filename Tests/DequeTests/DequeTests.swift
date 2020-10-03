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
    
    // MARK: - push(_:) and push(contentsOf:) tests
    func testPushElement() {
        var prevCount = sut.count
        sut.push(1)
        XCTAssertEqual(sut.count, prevCount + 1)
        XCTAssertEqual(sut.first, 1)
        
        prevCount = sut.count
        sut.push(2)
        XCTAssertEqual(sut.count, prevCount + 1)
        XCTAssertEqual(sut.first, 2)
        
        // value semantics:
        prevCount = sut.count
        var copy = sut!
        copy.push(3)
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.first, 2)
        XCTAssertEqual(copy.count, prevCount + 1)
        XCTAssertEqual(copy.first, 3)
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testPushContentsOfSequence() {
        let emptySequence = AnySequence<Int>([])
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        sut.push(contentsOf: emptySequence)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        
        var prevCount = sut.count
        let sequence = AnySequence([1, 2, 3, 4, 5])
        sut.push(contentsOf: sequence)
        XCTAssertEqual(sut.count, prevCount + 5)
        XCTAssertEqual(sut.first, 5)
        XCTAssertEqual(sut.last, 1)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5].reversed())
        
        prevCount = sut.count
        sut.push(contentsOf: emptySequence)
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.first, 5)
        XCTAssertEqual(sut.last, 1)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5].reversed())
        
        // value semantics:
        prevCount = sut.count
        var copy = sut!
        copy.push(contentsOf: AnySequence([6, 7, 8, 9, 10]))
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.last, 1)
        XCTAssertEqual(sut.first, 5)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5].reversed())
        XCTAssertEqual(copy.count, prevCount + 5)
        XCTAssertEqual(copy.first, 10)
        XCTAssertEqual(copy.last, 1)
        XCTAssertEqual(Array(copy), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].reversed())
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testPushContentsOfCollection() {
        let emptyCollection = AnyCollection<Int>([])
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        sut.push(contentsOf: emptyCollection)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        
        var prevCount = sut.count
        let collection = AnyCollection([1, 2, 3, 4, 5])
        sut.push(contentsOf: collection)
        XCTAssertEqual(sut.count, prevCount + 5)
        XCTAssertEqual(sut.first, 5)
        XCTAssertEqual(sut.last, 1)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5].reversed())
        
        prevCount = sut.count
        sut.push(contentsOf: emptyCollection)
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.first, 5)
        XCTAssertEqual(sut.last, 1)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5].reversed())
        
        // value semantics:
        prevCount = sut.count
        var copy = sut!
        copy.push(contentsOf: AnyCollection([6, 7, 8, 9, 10]))
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.last, 1)
        XCTAssertEqual(sut.first, 5)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5].reversed())
        XCTAssertEqual(copy.count, prevCount + 5)
        XCTAssertEqual(copy.first, 10)
        XCTAssertEqual(copy.last, 1)
        XCTAssertEqual(Array(copy), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].reversed())
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    // MARK: - prepend(contentsOf:) tests
    func testPrependContentsOfSequence() {
        let emptySequence = AnySequence<Int>([])
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        sut.prepend(contentsOf: emptySequence)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        
        var prevCount = sut.count
        let sequence = AnySequence([1, 2, 3, 4, 5])
        sut.prepend(contentsOf: sequence)
        XCTAssertEqual(sut.count, prevCount + 5)
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(sut.last, 5)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5])
        
        prevCount = sut.count
        sut.prepend(contentsOf: emptySequence)
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(sut.last, 5)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5])
        
        // value semantics:
        prevCount = sut.count
        var copy = sut!
        copy.prepend(contentsOf: AnySequence([6, 7, 8, 9, 10]))
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.last, 5)
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5])
        XCTAssertEqual(copy.count, prevCount + 5)
        XCTAssertEqual(copy.first, 6)
        XCTAssertEqual(copy.last, 5)
        XCTAssertEqual(Array(copy), [6, 7, 8, 9, 10, 1, 2, 3, 4, 5])
        XCTAssertFalse(sut.storage === copy.storage)
        
        // When sequence implements
        // withContiguousStorageIfAvailable(_:) method:
        sut = Deque()
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        let empty = SequenceImplementingWithContiguousStorage(base: [])
        sut.prepend(contentsOf: empty)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        
        prevCount = sut.count
        let notEmpty = SequenceImplementingWithContiguousStorage(base: [1, 2, 3, 4, 5])
        sut.prepend(contentsOf: notEmpty)
        XCTAssertEqual(sut.count, prevCount + 5)
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(sut.last, 5)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5])
    }
    
    func testPrependContentsOfCollection() {
        let emptyCollection = AnyCollection<Int>([])
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        sut.prepend(contentsOf: emptyCollection)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        
        var prevCount = sut.count
        let collection = AnyCollection([1, 2, 3, 4, 5])
        sut.prepend(contentsOf: collection)
        XCTAssertEqual(sut.count, prevCount + 5)
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(sut.last, 5)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5])
        
        prevCount = sut.count
        sut.prepend(contentsOf: emptyCollection)
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(sut.last, 5)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5])
        
        // value semantics:
        prevCount = sut.count
        var copy = sut!
        copy.prepend(contentsOf: AnyCollection([6, 7, 8, 9, 10]))
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.last, 5)
        XCTAssertEqual(sut.first, 1)
        XCTAssertEqual(Array(sut), [1, 2, 3, 4, 5])
        XCTAssertEqual(copy.count, prevCount + 5)
        XCTAssertEqual(copy.first, 6)
        XCTAssertEqual(copy.last, 5)
        XCTAssertEqual(Array(copy), [6, 7, 8, 9, 10, 1, 2, 3, 4, 5])
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    // MARK: - Collection, BidirectionalCollection, MutableCollection, RandomAccessCollection tests
    // MARK: - Index tests
    func testIndex() {
        // startIndex, endIndex
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.startIndex, 0)
        XCTAssertEqual(sut.startIndex, sut.endIndex)
        XCTAssertEqual(sut.endIndex, sut.count)
        
        sut = [1, 2, 3, 4, 5]
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.startIndex, 0)
        XCTAssertGreaterThan(sut.endIndex, sut.startIndex)
        XCTAssertEqual(sut.endIndex, sut.count)
        
        // index(after:), index(before:),
        //formIndex(after:), formIndexBefore(:)
        
        var idx = sut.startIndex
        let nextIdx = sut.index(after: idx)
        XCTAssertGreaterThan(nextIdx, idx)
        XCTAssertEqual(nextIdx, idx + 1)
        
        sut.formIndex(after: &idx)
        XCTAssertEqual(idx, nextIdx)
        let beforeIdx = sut.index(before: idx)
        XCTAssertLessThan(beforeIdx, idx)
        XCTAssertEqual(beforeIdx, idx - 1)
        
        sut.formIndex(before: &idx)
        XCTAssertEqual(idx, beforeIdx)
        XCTAssertLessThan(idx, nextIdx)
        
        // index(_:, offsetBy:)
        let offsetBy3 = sut.index(sut.startIndex, offsetBy: 3)
        idx = sut.startIndex
        for _ in 1...3 {
            sut.formIndex(after: &idx)
        }
        XCTAssertEqual(offsetBy3, idx)
        
        let offsetByNegative3 = sut.index(sut.endIndex, offsetBy: -3)
        idx = sut.endIndex
        for _ in 1...3 {
            sut.formIndex(before: &idx)
        }
        XCTAssertEqual(offsetByNegative3, idx)
        
        
        // index(:_, offsetBy:, limitedBy:)
        let offsetByCountPlusOne = sut.index(sut.startIndex, offsetBy: (sut.count + 1), limitedBy: sut.endIndex)
        XCTAssertNil(offsetByCountPlusOne)
        
        let offsetByNegativeCountPlusOne = sut.index(sut.endIndex, offsetBy: -(sut.count + 1), limitedBy: sut.startIndex)
        XCTAssertNil(offsetByNegativeCountPlusOne)
        
        let limitedByEndIndex = sut.index(sut.startIndex, offsetBy: sut.count, limitedBy: sut.endIndex)
        XCTAssertNotNil(limitedByEndIndex)
        XCTAssertEqual(limitedByEndIndex, sut.index(sut.startIndex, offsetBy: sut.count))
        
        let limitedByStartIndex = sut.index(sut.endIndex, offsetBy: -sut.count, limitedBy: sut.startIndex)
        XCTAssertNotNil(limitedByStartIndex)
        XCTAssertEqual(limitedByStartIndex, sut.index(sut.endIndex, offsetBy: -sut.count))
        
        // distance(from:to:)
        XCTAssertGreaterThan(sut.endIndex, sut.startIndex)
        XCTAssertEqual(sut.distance(from: sut.startIndex, to: sut.endIndex), sut.count)
        XCTAssertGreaterThan(sut.distance(from: sut.startIndex, to: sut.endIndex), 0)
        
        XCTAssertGreaterThan(sut.endIndex, sut.startIndex)
        XCTAssertEqual(sut.distance(from: sut.endIndex, to: sut.startIndex), -sut.count)
        XCTAssertLessThan(sut.distance(from: sut.endIndex, to: sut.startIndex), 0)
        
        XCTAssertEqual(sut.distance(from: sut.startIndex, to: sut.startIndex), 0)
        XCTAssertEqual(sut.distance(from: sut.endIndex, to: sut.endIndex), 0)
        
        let midIdx = sut.endIndex / 2
        XCTAssertEqual(sut.distance(from: midIdx, to: sut.index(after: midIdx)), 1)
        XCTAssertEqual(sut.distance(from: midIdx, to: sut.index(before: midIdx)), -1)
    }
    
    // MARK: - subscripts tests
    func testSubscriptIndex() {
        sut = [1, 2, 3, 4, 5]
        XCTAssertEqual(sut[0], sut.first)
        XCTAssertEqual(sut[sut.count - 1], sut.last)
        for idx in 0..<sut.count {
            let expectedValue = idx + 1
            XCTAssertEqual(sut[idx], expectedValue)
            
            sut[idx] = expectedValue + 10
            XCTAssertEqual(sut[idx], expectedValue + 10)
        }
        
        // value semantics:
        var copy = sut!
        for idx in copy.startIndex..<copy.endIndex {
            copy[idx] -= 10
            XCTAssertNotEqual(sut[idx], copy[idx])
        }
        XCTAssertNotEqual(Array(sut), Array(copy))
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testSubscriptRange() {
        sut = [1, 2, 3, 4, 5]
        
        let slice = sut[1...3]
        for idx in slice.startIndex..<slice.endIndex {
            XCTAssertEqual(slice[idx], sut[idx])
        }
        
        var mutSlice = sut[1...3]
        for idx in mutSlice.startIndex..<mutSlice.endIndex {
            mutSlice[idx] += 10
        }
        
        sut[1...3] = mutSlice
        for idx in mutSlice.startIndex..<mutSlice.endIndex {
            XCTAssertEqual(sut[idx], mutSlice[idx])
        }
        
        // Value semantics:
        // sut was mutated after first slice was exctacted,
        // therefore:
        for idx in slice.startIndex..<slice.endIndex {
            XCTAssertNotEqual(slice[idx], sut[idx])
        }
        XCTAssertFalse(sut.storage === slice.base.storage)
        
        // Let's also check when mutating a slice:
        sut = [1, 2, 3, 4, 5]
        mutSlice = sut[1...3]
        for idx in mutSlice.startIndex..<mutSlice.endIndex {
            mutSlice[idx] += 10
        }
        
        for idx in mutSlice.startIndex..<mutSlice.endIndex {
            XCTAssertNotEqual(mutSlice[idx], sut[idx])
        }
        XCTAssertFalse(sut.storage === mutSlice.base.storage)
    }
    
    // MARK: - withContiguousMutableStorageIfAvailable(_:) and withContiguousStorageIfAvailable(_:) tests
    func testWithContiguousMutableStorageIfAvailable() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        let exp1 = expectation(description: "closure completes")
        let result1: Bool? = sut.withContiguousMutableStorageIfAvailable { _ in
            exp1.fulfill()
            
            return true
        }
        wait(for: [exp1], timeout: 1)
        XCTAssertNotNil(result1)
        XCTAssertNil(sut.storage)
        
        sut = [1, 2, 3, 4, 5]
        let expectedResult1 = [10, 20, 30, 40, 50]
        let exp2 = expectation(description: "closure completes")
        let result2: Bool? = sut.withContiguousMutableStorageIfAvailable { buff in
            for i in buff.startIndex..<buff.endIndex {
                buff[i] *= 10
            }
            exp2.fulfill()
            
            return true
        }
        wait(for: [exp2], timeout: 1)
        XCTAssertNotNil(result2)
        XCTAssertEqual(Array(sut), expectedResult1)
        
        // value semantics:
        var copy = sut!
        let exp3 = expectation(description: "closure completes")
        copy.withContiguousMutableStorageIfAvailable { buffer in
            exp3.fulfill()
            for i in buffer.startIndex..<buffer.endIndex {
                buffer[i] /= 10
            }
        }
        wait(for: [exp3], timeout: 1)
        XCTAssertNotEqual(Array(copy), Array(sut))
        XCTAssertFalse(copy.storage === sut.storage)
    }
    
    func testWithContiguousStorageIfAvailable() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        let exp1 = expectation(description: "closure completes")
        let result1: Bool? = sut.withContiguousStorageIfAvailable { _ in
            exp1.fulfill()
            
            return true
        }
        wait(for: [exp1], timeout: 1)
        XCTAssertNotNil(result1)
        XCTAssertNil(sut.storage)
        
        sut = [1, 2, 3, 4, 5]
        let exp2 = expectation(description: "closure completes")
        let rangeToPick = 1...3
        var copiedValues = [Int]()
        let result2: Bool? = sut.withContiguousStorageIfAvailable { buff in
            for i in rangeToPick {
                copiedValues.append(buff[i])
            }
            exp2.fulfill()
            
            return true
        }
        wait(for: [exp2], timeout: 1)
        XCTAssertNotNil(result2)
        XCTAssertEqual(copiedValues, Array(sut[rangeToPick]))
    }
    
    // MARK: - Functional Programming methods
    func testAllSatisfy() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertTrue(sut.allSatisfy { $0 == 10 })
        
        sut = [1, 2, 3, 4, 5]
        XCTAssertFalse(sut.allSatisfy { $0 == 10 })
        XCTAssertTrue(sut.allSatisfy { $0 <= 5 })
        
        let throwingPred: (Int) throws -> Bool = { _ in
            throw NSError(domain: "com.vdl.deque", code: 1, userInfo: nil)
        }
        XCTAssertThrowsError(try sut.allSatisfy(throwingPred))
    }
    
    func testForEach() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        var result = [Int]()
        sut.forEach { result.append($0) }
        XCTAssertEqual(result, [])
        
        sut = [1, 2, 3, 4, 5]
        result = []
        sut.forEach { result.append($0 * 10) }
        XCTAssertEqual(result, [10, 20, 30, 40 ,50])
    }
    
    func testFilter() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        var result = [Int]()
        result = sut.filter { $0 > 1 }
        XCTAssertTrue(result.isEmpty)
        
        sut = [1, 2, 3, 4, 5]
        result = sut.filter { $0 % 2 == 0 }
        XCTAssertEqual(result, [2, 4])
        
        let throwingPred: (Int) throws -> Bool = { _ in
            throw NSError(domain: "com.vdl.deque", code: 1, userInfo: nil)
        }
        
        XCTAssertThrowsError(try sut.filter(throwingPred))
    }
    
    func testMap() {
        XCTAssertTrue(sut.isEmpty)
        var result: [String] = sut.map { String($0) }
        XCTAssertTrue(result.isEmpty)
        
        sut = [1, 2, 3, 4, 5]
        result = sut.map { String($0) }
        XCTAssertEqual(result.count, sut.count)
        XCTAssertEqual(result, ["1", "2", "3", "4", "5"])
        
        let throwingTransform: (Int) throws -> String = { _ in
            throw NSError(domain: "com.vdl.deque", code: 1, userInfo: nil)
        }
        
        XCTAssertThrowsError(result = try sut.map(throwingTransform))
    }
    
    func testFlatMap() {
        XCTAssertTrue(sut.isEmpty)
        var result: [Int] = sut.flatMap {
            return [$0 * 10, $0 * 100, $0 * 1000]
        }
        XCTAssertTrue(result.isEmpty)
        
        sut = [1, 2, 3, 4, 5]
        result = sut.flatMap {
            return [$0 * 10, $0 * 100, $0 * 1000]
        }
        var expectedResult: [Int] = []
        for element in sut {
            let iterResult = [element * 10, element * 100, element * 1000]
            expectedResult.append(contentsOf: iterResult)
        }
        XCTAssertEqual(result, expectedResult)
        
        let throwingTransform: (Int) throws -> [Int] = { _ in
            throw NSError(domain: "com.vdl.deque", code: 1, userInfo: nil)
        }
        XCTAssertThrowsError(result = try sut.flatMap(throwingTransform))
    }
    
    func testCompactMap() {
        XCTAssertTrue(sut.isEmpty)
        var result: [Int] = sut.compactMap { return $0 % 2 == 0 ? $0 : nil }
        XCTAssertTrue(result.isEmpty)
        
        sut = [1, 2, 3, 4, 5]
        result = sut.compactMap { return $0 % 2 == 0 ? $0 : nil }
        XCTAssertEqual(result, [2, 4])
        
        let throwingTransform: (Int) throws -> Int? = { _ in
            throw NSError(domain: "com.vdl.deque", code: 1, userInfo: nil)
        }
        
        XCTAssertThrowsError(result = try sut.compactMap(throwingTransform))
    }
    
    func testReduce() {
        XCTAssertTrue(sut.isEmpty)
        var result: Int = sut.reduce(0, +)
        XCTAssertEqual(result, 0)
        
        sut = [1, 2, 3, 4, 5]
        result = sut.reduce(0, +)
        XCTAssertEqual(result, 0 + 1 + 2 + 3 + 4 + 5)
        
        let throwingUpdateAccumulatingResult: (Int, Int) throws -> Int = { _, _ in
            throw NSError(domain: "com.vdl.deque", code: 1, userInfo: nil)
        }
        
        XCTAssertThrowsError(result = try sut.reduce(0, throwingUpdateAccumulatingResult))
    }
    
    // MARK: - RangeReplaceableCollection tests
    func testReserveCapacity() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        sut.reserveCapacity(20)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNotNil(sut.storage)
        
        // when there are already enough free spots to cover it,
        // buffer doesn't get reallocated:
        sut.prepend(contentsOf: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        XCTAssertEqual(20 - sut.count, 10)
        let prevStorageBaseAddress = sut.storage?.unsafeBufferPointer.baseAddress
        sut.reserveCapacity(10)
        XCTAssertEqual(20 - sut.count, 10)
        XCTAssertTrue(sut.storage?.unsafeBufferPointer.baseAddress == prevStorageBaseAddress)
        
        // otherwise buffer gets reallocated to a bigger one:
        XCTAssertGreaterThan(50, 20 - sut.count)
        sut.reserveCapacity(50)
        XCTAssertFalse(sut.storage?.unsafeBufferPointer.baseAddress == prevStorageBaseAddress)
    }
    func testReplaceSubrange() {
        // main functionalities guaranteed by CircularBuffer method
        // replace(subrange:with:)
        // We just do a few basic tests here:
        sut = [1, 2, 3, 4, 5]
        sut.replaceSubrange(1...3, with: [20, 30, 40])
        XCTAssertEqual(Array(sut), [1, 20, 30, 40, 5])
        
        sut = [1, 2, 3, 4, 5]
        sut.replaceSubrange(sut.startIndex..<sut.startIndex, with: [10, 20, 30, 40, 50])
        XCTAssertEqual(Array(sut), [10, 20, 30, 40, 50, 1, 2, 3, 4, 5])
        
        sut.replaceSubrange(sut.endIndex..<sut.endIndex, with: [60, 70, 80, 90, 100])
        XCTAssertEqual(Array(sut), [10, 20, 30, 40, 50, 1, 2, 3, 4, 5, 60, 70, 80, 90, 100])
        
        sut.replaceSubrange(5..<10, with: [0])
        XCTAssertEqual(Array(sut), [10, 20, 30, 40, 50, 0, 60, 70, 80, 90, 100])
        
        sut.replaceSubrange(5..<6, with: [])
        XCTAssertEqual(Array(sut), [10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
        
        // When the storage is nil and nothing gets added by the
        // replace, then storage stills nil:
        sut = Deque<Int>()
        XCTAssertNil(sut.storage)
        sut.replaceSubrange(0..<0, with: [])
        XCTAssertNil(sut.storage)
        
        // when storage is not nil, and replace erases all elements,
        // then storage becomes nil:
        sut = [1, 2, 3, 4, 5]
        XCTAssertNotNil(sut.storage)
        sut.replaceSubrange(sut.startIndex..<sut.endIndex, with: [])
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.storage)
        
        // value semantics:
        sut = [1, 2, 3, 4, 5]
        var copy = sut!
        copy.replaceSubrange(copy.startIndex..., with: [10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
        XCTAssertEqual(Array(copy), [10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
        XCTAssertNotEqual(Array(copy), Array(sut))
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testAppendElement() {
        // Main functionalities backed by CircularBuffer.
        // We are just gonna check value semnatics here:
        var copy = sut!
        copy.append(1)
        XCTAssertNotEqual(Array(copy), Array(sut))
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testAppendContentsOfSequence() {
        // Main functionalities are backed by CircularBuffer.
        // We are gonna test a special case here: when storage
        // is nil and sequence to add contains no elements, then
        // storage is still equal to nil
        XCTAssertNil(sut.storage)
        sut.append(contentsOf: [])
        XCTAssertNil(sut.storage)
        
        // …and test value semantics too:
        var copy = sut!
        copy.append(contentsOf: [1, 2, 3, 4, 5])
        XCTAssertNotEqual(Array(copy), Array(sut))
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testInsertElementAt() {
        // Main functionalities are backed by CircularBuffer.
        // We are going to just test value semantics here:
        
        sut = [1, 2, 3, 4, 5]
        var copy = sut!
        copy.insert(0, at: 0)
        XCTAssertNotEqual(Array(copy), Array(sut))
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testInsertContentsOfCollectionAt() {
        // Main functionalities are backed by CircularBuffer,
        // therefore we jsut test a special case here: when storage
        // is empty and collection is empty too, then storage is
        // still equal to nil.
        XCTAssertNil(sut.storage)
        sut.insert(contentsOf: [], at: sut.endIndex)
        XCTAssertNil(sut.storage)
        
        // …and of course we also test value semantics:
        var copy = sut!
        copy.insert(contentsOf: [1, 2, 3, 4, 5], at: copy.endIndex)
        XCTAssertNotEqual(Array(copy), Array(sut))
        XCTAssertFalse(sut.storage === copy.storage)
    }
    
    func testRemoveElementAt() {
        XCTFail("Must implement this test!")
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

struct SequenceImplementingWithContiguousStorage: Sequence {
    let base: Array<Int>

    
    typealias Element = Int
    
     typealias Iterator = AnyIterator<Int>
    
    func makeIterator() -> Iterator {
        var idx = 0
        
        return AnyIterator<Int> {
            guard idx < base.count else { return nil }
            
            defer { idx += 1 }
            
            return base[idx]
        }
    }
    
    func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Int>) throws -> R) rethrows -> R? {
        
        return try base.withContiguousStorageIfAvailable(body)
    }
    
}


