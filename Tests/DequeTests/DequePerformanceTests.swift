//
//  DequePerformanceTests.swift
//  DequeTests
//
//  Created by Valeriano Della Longa on 2020/12/11.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import XCTest
import Deque
import CircularBuffer

final class DequePerformanceTests: XCTestCase {
    func testDequePerformanceAtSmallCount() {
        measure(performanceLoopDequeSmallCount)
    }
    
    func testArrayPerformanceAtSmallCount() {
        measure(performanceLoopArraySmallCount)
    }
    
    func testCircularBufferPerformanceAtSmallCount() {
        measure(performanceLoopCircularBufferSmallCount)
    }
    
    func testDequePreformanceAtLargeCount() {
        measure(performanceLoopDequeLargeCount)
    }
    
    func testArrayPerformanceAtLargeCount() {
        measure(performanceLoopArrayLargeCount)
    }
    
    func testCircularBufferPerformanceAtLargeCount() {
        measure(performanceLoopCircularBufferLargeCount)
    }
    
    // MARK: - Private helpers
    private func performanceLoopDequeSmallCount() {
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
    
    private func performanceLoopArraySmallCount() {
        let outerCount: Int = 10_000
        let innerCount: Int = 20
        var accumulator = 0
        for _ in 1...outerCount {
            var array = Array<Int>()
            array.reserveCapacity(innerCount)
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
    
    private func performanceLoopCircularBufferSmallCount() {
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
    
    private func performanceLoopDequeLargeCount() {
        let outerCount: Int = 10
        let innerCount: Int = 20_000
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
    
    private func performanceLoopArrayLargeCount() {
        let outerCount: Int = 10
        let innerCount: Int = 20_000
        var accumulator = 0
        for _ in 1...outerCount {
            var array = Array<Int>()
            array.reserveCapacity(innerCount)
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
    
    private func performanceLoopCircularBufferLargeCount() {
        let outerCount: Int = 10
        let innerCount: Int = 20_000
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
