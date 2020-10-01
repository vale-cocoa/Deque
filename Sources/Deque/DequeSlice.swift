//
//  DequeSlice.swift
//  Deque
//
//  Created by Valeriano Della Longa on 30/09/2020.
//  
import CircularBuffer

public struct DequeSlice<Element> {
    public typealias Base = Deque<Element>
    
    #if swift(>=4.1) || (swift(>=3.3) && !swift(>=4.0))
    public typealias _Slice = Slice<Base>
    #else
    public typealias _Slice = RangeReplaceableRandomAccessSlice<Base>
    #endif
    
    private(set) var _slice: _Slice
    
    public private(set) var base: Base {
        get { _slice.base }
        set { _slice = Slice(base: newValue, bounds: bounds) }
    }
    
    public var bounds: Range<Base.Index> {
        _slice.startIndex..<_slice.endIndex
    }
    
    public init(base: Base, bounds: Range<Base.Index>) {
        self._slice = Slice(base: base, bounds: bounds)
    }
    
}

extension DequeSlice: Collection, MutableCollection, BidirectionalCollection {
    public typealias Index = Base.Index
    
    public typealias Subsequence = Self
    
    public typealias Indices = Slice<Base>.Indices
    
    public typealias Element = Base.Element
    
    public typealias Iterator = Slice<Base>.Iterator
    
    public var startIndex: Base.Index { _slice.startIndex }
    
    public var endIndex: Base.Index { _slice.endIndex }
    
    public var count: Int { _slice.count }
    
    public var isEmpty: Bool { _slice.isEmpty }
    
    public __consuming func makeIterator() -> Slice<Base>.Iterator {
        _slice.makeIterator()
    }
    
    public var indices: Slice<Base>.Indices {
        _slice.indices
    }
    
    public subscript(position: Base.Index) -> Element {
        get { _slice[position] }
        set { _slice[position] = newValue }
    }
    
    public subscript(bounds: Range<Base.Index>) -> Subsequence {
        get { DequeSlice(base: base, bounds: bounds) }
        set { replaceSubrange(bounds, with: newValue) }
    }
    
    public func index(after i: Base.Index) -> Base.Index {
        _slice.index(after: i)
    }
    
    public func formIndex(after i: inout Base.Index) {
        _slice.formIndex(after: &i)
    }
    
    public func index(before i: Base.Index) -> Base.Index {
        _slice.index(before: i)
    }
    
    public func formIndex(before i: inout Base.Index) {
        _slice.formIndex(before: &i)
    }
    
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Base.Element>) throws -> R) rethrows -> R? {
        try base
            .withContiguousStorageIfAvailable { buffer in
                let sliced = UnsafeBufferPointer(rebasing: buffer[bounds])
                
                return try body(sliced)
            }
    }
    
    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Base.Element>) throws -> R) rethrows -> R? {
        let bufferBounds = bounds
        
        return try base
            .withContiguousMutableStorageIfAvailable { buffer in
                var sliced = UnsafeMutableBufferPointer(rebasing: buffer[bufferBounds])
                let copy = sliced
                defer {
                    precondition(
                        sliced.baseAddress == copy.baseAddress &&
                        sliced.count == copy.count,
                        "DequeSlice.withUnsafeMutableBufferPointer: replacing the buffer is not allowed"
                    )
                }
                
                return try body(&sliced)
            }
    }
    
}

extension DequeSlice: RandomAccessCollection {
    public func index(_ i: Base.Index, offsetBy distance: Int) -> Base.Index {
        _slice.index(i, offsetBy: distance)
    }
    
    public func index(_ i: Base.Index, offsetBy distance: Int, limitedBy limit: Base.Index) -> Base.Index? {
        _slice.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    public func distance(from start: Base.Index, to end: Base.Index) -> Int {
        _slice.distance(from: start, to: end)
    }
    
}

extension DequeSlice: RangeReplaceableCollection {
    public init() {
        self._slice = Slice(base: Deque(), bounds: 0..<0)
    }
    
    public init(repeating repeatedValue: Base.Element, count: Int) {
        let base = Deque(repeating: repeatedValue, count: count)
        self._slice = Slice(base: base, bounds: base.startIndex..<base.endIndex)
    }
    
    public init<S>(_ elements: S) where S : Sequence, Self.Element == S.Element {
        let base = Deque(elements: elements)
        self._slice = Slice(base: base, bounds: base.startIndex..<base.endIndex)
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Base.Index>, with newElements: C) where C : Collection, Self.Element == C.Element {
        _slice.replaceSubrange(subrange, with: newElements)
    }
    
    public mutating func insert(_ newElement: Base.Element, at i: Base.Index) {
        _slice.insert(newElement, at: i)
    }
    
    public mutating func insert<S>(contentsOf newElements: S, at i: Base.Index) where S : Collection, Self.Element == S.Element {
        _slice.insert(contentsOf: newElements, at: i)
    }
    
    public mutating func remove(at i: Base.Index) -> Base.Element {
        _slice.remove(at: i)
    }
    
    public mutating func removeSubrange(_ bounds: Range<Base.Index>) {
        _slice.removeSubrange(bounds)
    }
    
}
