//
//  Helpers.swift
//  DequeTests
//
//  Created by Valeriano Della Longa on 03/10/2020.
//
import XCTest
import CircularBuffer
@testable import Deque

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

protocol EquatableCollectionUsingCircularBuffer: Collection where Element: Equatable {
    var storage: CircularBuffer<Element>? { get }
}

extension Deque: EquatableCollectionUsingCircularBuffer where Element: Comparable {  }

extension DequeSlice: EquatableCollectionUsingCircularBuffer where Element: Comparable {
    var storage: CircularBuffer<Base.Element>? {
        _slice.base.storage
    }
    
}

func assertAreDifferentValuesAndHaveDifferentStorage<C: EquatableCollectionUsingCircularBuffer, D: EquatableCollectionUsingCircularBuffer>(sut: C, copy: D, file: StaticString = #file, line: UInt = #line) where C.Element == D.Element {
    XCTAssertNotEqual(Array(copy), Array(sut), "copy contains same elements of original after mutation", file: file, line: line)
    XCTAssertFalse(sut.storage === copy.storage, "copy has same storage instance of original", file: file, line: line)
}

