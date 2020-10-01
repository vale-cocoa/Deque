//
//  DequeSlice.swift
//  Deque
//
//  Created by Valeriano Della Longa on 30/09/2020.
//  
import CircularBuffer

public struct DequeSlice<Element> {
    public typealias Base = Deque<Element>
    
    private(set) var slice: Slice<Base>
    
    public private(set) var base: Base {
        get { slice.base }
        set { slice = Slice(base: newValue, bounds: bounds) }
    }
    
    public private(set) var bounds: Range<Base.Index>
    
    public init(base: Base, bounds: Range<Base.Index>) {
        self.bounds = bounds
        self.slice = Slice(base: base, bounds: bounds)
    }
    
}

extension DequeSlice: Collection, MutableCollection, BidirectionalCollection {
    public typealias Index = Base.Index
    
    public typealias Subsequence = Self
    
    public typealias Indices = Slice<Base>.Indices
    
    public typealias Element = Base.Element
    
    public typealias Iterator = Slice<Base>.Iterator
    
    public var startIndex: Base.Index { slice.startIndex }
    
    public var endIndex: Base.Index { slice.endIndex }
    
    public var count: Int { slice.count }
    
    public var isEmpty: Bool { slice.isEmpty }
    
    public __consuming func makeIterator() -> Slice<Base>.Iterator {
        slice.makeIterator()
    }
    
    public var indices: Slice<Base>.Indices {
        slice.indices
    }
    
    public subscript(position: Base.Index) -> Element {
        get { slice[position] }
        set { slice[position] = newValue }
    }
    
    public subscript(bounds: Range<Base.Index>) -> Subsequence {
        get { DequeSlice(base: base, bounds: bounds) }
        set { replaceSubrange(bounds, with: newValue) }
    }
    
    public func index(after i: Base.Index) -> Base.Index {
        slice.index(after: i)
    }
    
    public func formIndex(after i: inout Base.Index) {
        slice.formIndex(after: &i)
    }
    
    public func index(before i: Base.Index) -> Base.Index {
        slice.index(before: i)
    }
    
    public func formIndex(before i: inout Base.Index) {
        slice.formIndex(before: &i)
    }
    
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Base.Element>) throws -> R) rethrows -> R? {
        try base
            .withContiguousStorageIfAvailable { buffer in
                let sliced = UnsafeBufferPointer(rebasing: buffer[bounds])
                
                return try body(sliced)
            }
    }
    
    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Base.Element>) throws -> R) rethrows -> R? {
        let rangeOfBuffer = bounds
        
        return try base
            .withContiguousMutableStorageIfAvailable { buffer in
                var sliced = UnsafeMutableBufferPointer(rebasing: buffer[rangeOfBuffer])
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
        slice.index(i, offsetBy: distance)
    }
    
    public func index(_ i: Base.Index, offsetBy distance: Int, limitedBy limit: Base.Index) -> Base.Index? {
        slice.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    public func distance(from start: Base.Index, to end: Base.Index) -> Int {
        slice.distance(from: start, to: end)
    }
    
}

extension DequeSlice: RangeReplaceableCollection {
    public init() {
        self.slice = Slice(base: Deque(), bounds: 0..<0)
        self.bounds = 0..<0
    }
    
    public init(repeating repeatedValue: Base.Element, count: Int) {
        let base = Deque(repeating: repeatedValue, count: count)
        self.slice = Slice(base: base, bounds: base.startIndex..<base.endIndex)
        self.bounds = base.startIndex..<base.endIndex
    }
    
    public init<S>(_ elements: S) where S : Sequence, Self.Element == S.Element {
        let base = Deque(elements: elements)
        self.slice = Slice(base: base, bounds: base.startIndex..<base.endIndex)
        self.bounds = base.startIndex..<base.endIndex
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Base.Index>, with newElements: C) where C : Collection, Self.Element == C.Element {
        slice.replaceSubrange(subrange, with: newElements)
    }
    
    public mutating func insert(_ newElement: Base.Element, at i: Base.Index) {
        slice.insert(newElement, at: i)
    }
    
    public mutating func insert<S>(contentsOf newElements: S, at i: Base.Index) where S : Collection, Self.Element == S.Element {
        slice.insert(contentsOf: newElements, at: i)
    }
    
    public mutating func remove(at i: Base.Index) -> Base.Element {
        slice.remove(at: i)
    }
    
    public mutating func removeSubrange(_ bounds: Range<Base.Index>) {
        slice.removeSubrange(bounds)
    }
    
}

/*
public struct DequeSlice<Element> {
    public private(set) var base: Deque<Element>
    public private(set) var indices: CountableRange<Int>
    
    public init<R>(base: Deque<Element>, bounds: R) where R: RangeExpression, R.Bound == Int {
        self.base = base
        self.indices = bounds.relative(to: base.indices)
    }
    
    public var count: Int { indices.count }
    
    public var isEmpty: Bool { indices.isEmpty }
}

extension DequeSlice: Collection, MutableCollection {
    public typealias Index = Int
    
    public typealias SubSequence = Self
    
    public var startIndex: Int { indices.lowerBound }
    
    public var endIndex: Int { indices.lowerBound + indices.count }
    
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public func formIndex(after i: inout Int) {
        i += 1
    }
    
    public subscript(position: Int) -> Element {
        get {
            _checkSubscript(position)
            return base[position]
        }
        
        set(newValue) {
            _checkSubscript(position)
            base[position] = newValue
        }
        
    }
    
    public subscript(bounds: Range<Int>) -> DequeSlice<Element> {
        get {
            _checkSubrange(bounds)
            
            return DequeSlice(base: base, bounds: bounds)
        }
        
        set {
            _checkSubrange(bounds)
            base.replaceSubrange(bounds, with: newValue)
        }
    }
    
    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for idx in indices where try predicate(base[idx]) == false {
            
            return false
        }
        
        return true
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        for idx in indices {
            try body(base[idx])
        }
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        try compactMap { try isIncluded($0) ? $0 : nil }
    }
    
    public func map<T>(_ body: (Element) throws -> T) rethrows -> [T] {
        var result = [T]()
        try forEach { result.append(try body($0)) }
        
        return result
    }
    
    public func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult: Sequence {
        var result = [SegmentOfResult.Element]()
        try forEach { result.append(contentsOf: try transform($0)) }
        
        return result
    }
    
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        
        return try compactMap(transform)
    }
    
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        var result = [T]()
        try forEach { element in
            try transform(element).map { result.append($0) }
        }
        
        return result
    }
    
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        var finalResult = initialResult
        try forEach {
            try updateAccumulatingResult(&finalResult, $0)
        }
        
        return finalResult
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        try reduce(into: initialResult) { accumulator, element in
            accumulator = try nextPartialResult(accumulator, element)
        }
    }
    
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
        
        return try base.withContiguousStorageIfAvailable { baseBuff in
            let thisBuff = UnsafeBufferPointer(start: baseBuff.baseAddress?.advanced(by: indices.lowerBound), count: indices.count)
            
            return try body(thisBuff)
        }
    }
    
    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R? {
        // Ensure that body can't invalidate the storage or its
        // bounds by moving self into a temporary working
        // DequeSlice.
        // NOTE: The stack promotion optimization that keys of the
        // "dequeSlice.withContiguousMutableStorageIfAvailable"
        // semantics annotation relies on the DequeSlice buffer not
        // being able to escape in the closure.
        // It can do this because we swap the DequeSlice buffer
        // in self with an empty buffer here.
        // Any escape via the address of self in the closure will
        // therefore escape the empty DequeSlice.
        var work = DequeSlice()
        (work, self) = (self, work)
        // Create an UnsafeMutableBufferPointer over work that we
        // can pass to body
        var inoutBuffer = work.base
                .withContiguousMutableStorageIfAvailable { baseBuff in
                    return UnsafeMutableBufferPointer(
                        start: baseBuff.baseAddress?
                            .advanced(by: work.indices.lowerBound),
                        count: work.indices.count)
                }
        
        guard
            inoutBuffer != nil
        else {
            // Put back in place the DequeSlice
            defer {
                (work, self) = (self, work)
            }
            
            return nil
        }
        
        let basePointer = inoutBuffer!.baseAddress
        let initialCount = inoutBuffer!.count
        // Put back in place the DequeSlice
        defer {
            precondition(basePointer == inoutBuffer!.baseAddress && initialCount == inoutBuffer!.count, "DequeSlice withContiguousMutableStorageIfAvailable: replacing the buffer is not allowed")
            (work, self) = (self, work)
        }
        
        // Invoke body
        return try body(&inoutBuffer!)
    }
    
}

extension DequeSlice: BidirectionalCollection {
    public func index(before i: Int) -> Int {
        i - 1
    }
    
    public func formIndex(before i: inout Int) {
        i -= 1
    }
    
}

extension DequeSlice: RandomAccessCollection {
    public func distance(from start: Int, to end: Int) -> Int {
        end - start
    }
    
    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        i + distance
    }
    
    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        let l = limit - i
        
        if distance > 0 ? (l >= 0 && l < distance) : (l <= 0 && distance < l) {
            
            return nil
        }
        
        return i + distance
    }
    
}

extension DequeSlice: RangeReplaceableCollection {
    public init() {
        base = Deque()
        indices = 0..<0
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Self.Element == C.Element {
        let newCount = count - subrange.count + newElements.count
        _checkSubrange(subrange)
        base.replaceSubrange(subrange, with: newElements)
        indices = indices.lowerBound..<(indices.lowerBound + newCount)
    }
    
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        let newCount = count - bounds.count
        _checkSubrange(bounds)
        base.removeSubrange(bounds)
        indices = indices.lowerBound..<(indices.lowerBound + newCount)
    }
    
}

extension DequeSlice {
    @inline(__always)
    private func _checkSubscript(_ position: Int) {
        guard indices ~= position else { fatalError("Index out of bounds") }
    }
    
    private func _checkSubrange(_ subrange: Range<Int>) {
        guard
            subrange.lowerBound >= startIndex,
            subrange.lowerBound <= endIndex,
            subrange.upperBound <= endIndex,
            subrange.count <= count
            
        else { fatalError("Subrange out of bounds")}
    }
    
}
*/

