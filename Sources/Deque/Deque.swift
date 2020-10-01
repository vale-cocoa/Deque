//
//  Deque.swift
//  Deque
//
//  Created by Valeriano Della Longa on 29/09/2020.
//
import CircularBuffer

/// A double ended queue, that is a queue which allows acces to its both ends with an
/// amortized O(1) complexity.
///
/// `Deque` is an ordered, random-access collection, It basically presents the same
/// interface and behavior of an array (including value semantics), but with the advantage
/// of an amortized O(1) complexity for operations on the first position of its storage,
/// rather than O(*n*) as arrays do.
public struct Deque<Element> {
    private(set) var storage: CircularBuffer<Element>? = nil
    
    /// Returns a new empty `Deque` instance.
    public init() { }
    
    /// Returns a new `Deque` instance initialized with the contents of the given
    /// sequence of elements.
    ///
    /// - Parameter _: the sequence of elements to initialize with.
    /// - Returns:  a new `Deque` instance containing all the elements of the given
    ///             sequence, stored in the same order.
    /// - Complexity:   O(*n*) where *n* is the number of elements of the given
    ///                 sequence. Amortized O(1) in case the given sequence's
    ///                 method
    ///                 `withContiguousStorageIfAvailable(_:)` offers a
    ///                 view into all its elements.
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == Element {
        let newStorage = CircularBuffer(elements: elements)
        guard !newStorage.isEmpty else { return }
        
        storage = newStorage
    }
    
    /// Returns a new `Deque` instance initialized with the contents of the given
    /// collection of elements.
    ///
    /// - Parameter _: the collection of elements to initialize with.
    /// - Returns:  a new `Deque` instance containing all the elements of the given
    ///             collection, stored in the same order.
    /// - Complexity:   O(*n*) where *n* is count of elements of the given
    ///                 collection. Amortized O(1) in case the given collection's
    ///                 method
    ///                 `withContiguousStorageIfAvailable(_:)` offers a
    ///                 view into all its stored elements.
    public init<C: Collection>(_ elements: C) where C.Iterator.Element == Element {
        guard !elements.isEmpty else { return }
        
        storage = CircularBuffer(elements: elements)
    }
    
}

// MARK: - Public Interface
extension Deque {
    /// The first element stored in this deque. `Nil` when `isEmpty` is equal to
    /// `true`.
    ///
    /// - Note: equals `last` when `count` is equal to `1` or when `isEmpty` is
    ///         equal to `true`.
    public var first: Element? { storage?.first }
    
    /// The last element stored in this deque. `Nil` when `isEmpty` is equal to
    /// `true`.
    ///
    /// - Note: equals `first` when `count` is equal to `1` or when `isEmpty`
    ///         is equal to `true`.
    public var last: Element? { storage?.last }
    
    /// Add a new element to this queue.
    ///
    /// - Parameter _: the new element to add to the queue.
    /// - Note: equivalent to using `append(_:)` method.
    public mutating func enqueue(_ newElement: Element) {
        append(newElement)
    }
    
    /// Adds –in the same order– the elments  contained in the given sequence to this
    /// queue.
    ///
    /// - Parameter contentsOf: the sequence of elements to add.
    /// - Note: equivalent to using `append(contentsOf:)` method.
    public mutating func enqueue<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
        append(contentsOf: newElements)
    }
    
    @discardableResult
    public mutating func dequeue() -> Element? {
        _makeUnique()
        
        return storage?.popFirst()
    }
    
    @discardableResult
    public mutating func dequeue(_ k: Int) -> [Element] {
        _makeUnique()
        
        return storage!.removeFirst(k)
    }
    
    public mutating func push(_ newElement: Element) {
        _makeUnique()
        storage!.push(newElement)
    }
    
    public mutating func push<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
        _makeUnique(additionalCapacity: newElements.underestimatedCount)
        storage!.push(contentsOf: newElements)
        _checkForEmptyAtEndOfMutation()
    }
    
    public mutating func push<C: Collection>(contentsOf newElements: C) where C.Iterator.Element == Element {
        _makeUnique(additionalCapacity: newElements.count)
        storage!.prepend(contentsOf: newElements.reversed())
        _checkForEmptyAtEndOfMutation()
    }
    
    public mutating func prepend<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
        _makeUnique(additionalCapacity: newElements.underestimatedCount)
        guard
            let _ = newElements
                .withContiguousStorageIfAvailable ({ buffer -> Bool in
                    self.storage!.prepend(contentsOf: buffer)
                    
                    return true
                })
        else {
            var newElementsIterator = newElements.lazy.reversed().makeIterator()
            while let nextElement = newElementsIterator.next() {
                self.storage!.push(nextElement)
            }
            _checkForEmptyAtEndOfMutation()
            
            return
        }
        
        _checkForEmptyAtEndOfMutation()
    }
    
    public mutating func prepend<C: Collection>(contentsOf newElements: C) where C.Iterator.Element == Element {
        _makeUnique(additionalCapacity: newElements.count)
        storage!.prepend(contentsOf: newElements)
        _checkForEmptyAtEndOfMutation()
    }
    
}

// MARK: - MutableCollection conformance
extension Deque: Collection, MutableCollection {
    public typealias Index = Int
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Iterator = IndexingIterator<Deque<Element>>
    
    public typealias SubSequence = DequeSlice<Element>
    
    public var startIndex: Int { 0 }
    
    public var endIndex: Int { storage?.count ?? 0 }
    
    public var count: Int { storage?.count ?? 0}
    
    public var isEmpty: Bool { storage?.isEmpty ?? true }
    
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public func formIndex(after i: inout Int) {
        i += 1
    }
    
    public subscript(position: Int) -> Element {
        get {
            storage![position]
        }
        
        set {
            _makeUnique()
            storage![position] = newValue
        }
    }
    
    public subscript(bounds: Range<Int>) -> SubSequence {
            get {
                
                return SubSequence(base: self, bounds: bounds)
            }
        
            set {
                self.replaceSubrange(bounds, with: newValue)
            }
    }
    
    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R? {
        _makeUnique()
        
        // Ensure that body can't invalidate the storage or its
        // bounds by moving self into a temporary working Deque.
        // NOTE: The stack promotion optimization that keys of the
        // "deque.withContiguousMutableStorageIfAvailable"
        // semantics annotation relies on the Deque buffer not
        // being able to escape in the closure.
        // It can do this because we swap the Deque buffer in self
        // with an empty buffer here.
        // Any escape via the address of self in the closure will
        // therefore escape the empty Deque.
        var work = Deque()
        (work, self) = (self, work)
        
        // Create an UnsafeMutableBufferPointer over work that we
        // can pass to body
        var inoutBuffer = work.storage?.unsafeMutableBufferPointer ?? UnsafeMutableBufferPointer<Element>(start: nil, count: 0)
        let basePointer = inoutBuffer.baseAddress
        let initialCount = inoutBuffer.count
        
        // Put back in place the Deque
        defer {
            precondition(basePointer == inoutBuffer.baseAddress && initialCount == inoutBuffer.count, "Deque withContiguousMutableStorageIfAvailable: replacing the buffer is not allowed")
            (work, self) = (self, work)
        }
        
        // Invoke body
        return try body(&inoutBuffer)
    }
    
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
        
        return try body(storage?.unsafeBufferPointer ?? UnsafeBufferPointer<Element>(start: nil, count: 0))
    }
    
    // MARK: - Functional methods
    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for element in self where try predicate(element) == false {
            
            return false
        }
        
        return true
    }
    
    public func forEach(_ body: (Element) throws -> ()) rethrows {
        try storage?.forEach(body)
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        try compactMap { try isIncluded($0) ? $0 : nil }
    }
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        var result = [T]()
        try storage?.forEach { element in
            let transformed = try transform(element)
            result.append(transformed)
        }
        
        return result
    }
    
    public func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult: Sequence {
        var result = [SegmentOfResult.Element]()
        try storage?.forEach {
            let iterResult = try transform($0)
            result.append(contentsOf: iterResult)
        }
        
        return result
    }
    
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        
        return try compactMap(transform)
    }
    
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        var result = [T]()
        try storage?.forEach { element in
            try transform(element).map { result.append($0) }
        }
        
        return result
    }
    
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        var finalResult = initialResult
        try storage?.forEach {
            try updateAccumulatingResult(&finalResult, $0)
        }
        
        return finalResult
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        try reduce(into: initialResult) { accumulator, element in
            accumulator = try nextPartialResult(accumulator, element)
        }
    }
    
}

// MARK: - BidirectionalCollection conformance
extension Deque: BidirectionalCollection {
    public func index(before i: Int) -> Int {
        i - 1
    }
    
    public func formIndex(before i: inout Int) {
        i -= 1
    }
    
}

// MARK: - RandomAccessCollection conformance
extension Deque: RandomAccessCollection {
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
    
    public func distance(from start: Int, to end: Int) -> Int {
        end - start
    }
    
}

// MARK: - RangeReplaceableCollection conformance
extension Deque: RangeReplaceableCollection {
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Self.Element == C.Element {
        let difference = count - subrange.count + newElements.count
        let additionalCapacity = difference < 0 ? -difference : 0
        _makeUnique(additionalCapacity: additionalCapacity)
        storage!.replace(subRange: subrange, with: newElements)
        _checkForEmptyAtEndOfMutation()
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        let additionalCapacity = n - count > 0 ? n - count : 0
        _makeUnique(additionalCapacity: additionalCapacity)
    }
    
    public init(repeating repeatedValue: Element, count: Int) {
        guard count > 0 else { return }
        
        self.storage = CircularBuffer(repeating: repeatedValue, count: count)
    }
    
    public mutating func append(_ newElement: Self.Element) {
        _makeUnique()
        storage!.append(newElement)
    }
    
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Self.Element == S.Iterator.Element {
        _makeUnique(additionalCapacity: newElements.underestimatedCount)
        storage!.append(contentsOf: newElements)
        _checkForEmptyAtEndOfMutation()
    }
    
    public mutating func insert(_ newElement: Self.Element, at i: Self.Index) {
        _makeUnique()
        storage!.insertAt(index: i, contentsOf: CollectionOfOne(newElement))
    }
    
    public mutating func insert<S>(contentsOf newElements: S, at i: Self.Index) where S : Collection, Self.Element == S.Element {
        _makeUnique(additionalCapacity: newElements.underestimatedCount)
        storage!.insertAt(index: i, contentsOf: newElements)
        _checkForEmptyAtEndOfMutation()
    }
    
    public mutating func remove(at i: Self.Index) -> Self.Element {
        _makeUnique()
        defer {
            _checkForEmptyAtEndOfMutation()
        }
        
        return storage!.removeAt(index: i, count: 1).first!
    }
    
    public mutating func removeSubrange(_ bounds: Range<Self.Index>) {
        let subrange = bounds.relative(to: indices)
        guard subrange.count > 0 else { return }
        
        _makeUnique()
        storage!.removeAt(index: subrange.lowerBound, count: subrange.count)
        _checkForEmptyAtEndOfMutation()
    }
    
    public mutating func removeFirst() -> Self.Element {
        _makeUnique()
        defer {
            _checkForEmptyAtEndOfMutation()
        }
        
        return storage!.removeFirst(1, keepCapacity: false).first!
    }
    
    public mutating func removeFirst(_ k: Int) {
        _makeUnique()
        storage!.removeFirst(k, keepCapacity: false)
        _checkForEmptyAtEndOfMutation()
    }
    
    @available(*, deprecated, renamed: "removeAll(keepingCapacity:)")
    public mutating func removeAll(keepCapacity: Bool) {
        self.removeAll(keepingCapacity: keepCapacity)
    }
    
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        guard storage != nil else { return }
        
        _makeUnique()
        guard keepCapacity else {
            storage = nil
            
            return
        }
        
        storage!.removeAll(keepCapacity: keepCapacity)
    }
    
    public mutating func removeAll(where shouldBeRemoved: (Self.Element) throws -> Bool) rethrows {
        guard storage != nil else { return }
        
        _makeUnique()
        var ranges = [Range<Int>]()
        var currRange: Range<Int>? = nil
        var currIdx = 0
        try storage!.forEach { element in
            if try shouldBeRemoved(element) {
                currRange = (currRange?.lowerBound ?? currIdx)..<currIdx + 1
            } else if let newRange = currRange {
                ranges.append(newRange)
                currRange = nil
            }
            currIdx += 1
        }
        if let newRange = currRange {
            ranges.append(newRange)
        }
        
        ranges.forEach { rangeOfRemoval in
            self.storage!.removeAt(index: rangeOfRemoval.lowerBound, count: rangeOfRemoval.count, keepCapacity: false)
        }
        _checkForEmptyAtEndOfMutation()
    }
    
    @discardableResult
    public mutating func popLast() -> Element? {
        _makeUnique()
        defer {
            _checkForEmptyAtEndOfMutation()
        }
        
        return storage!.popLast()
    }
    
    @discardableResult
    public mutating func popFirst() -> Element? {
        _makeUnique()
        defer {
            _checkForEmptyAtEndOfMutation()
        }
        
        return storage!.popFirst()
    }
    
    public mutating func removeLast() -> Self.Element {
        _makeUnique()
        defer {
            _checkForEmptyAtEndOfMutation()
        }
        
        return storage!.removeLast(1).first!
    }
    
    public mutating func removeLast(_ k: Int) {
        _makeUnique()
        
        storage!.removeLast(k)
        _checkForEmptyAtEndOfMutation()
    }
    
}

// MARK: - ExpressibleByArrayLiteral conformance
extension Deque: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        guard !elements.isEmpty else { return }
        
        self.storage = CircularBuffer(elements: elements)
    }
    
}

// MARK: - Equatable Conformance
extension Deque: Equatable where Element: Equatable {
    public static func == (lhs: Deque<Element>, rhs: Deque<Element>) -> Bool {
        guard lhs.storage !== rhs.storage else { return true }
        
        guard lhs.count == rhs.count else { return false }
        
        for idx in 0..<lhs.count where lhs[idx] != rhs[idx] {
            
            return false
        }
        
        return true
    }
    
}

// MARK: - Hashable Conformance
extension Deque: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(count)
        self.storage?.forEach { hasher.combine($0) }
    }
    
}

// MARK: - Codable conformance
extension Deque: Codable where Element: Codable {
    private enum CodingKeys: String, CodingKey {
        case storage
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let elements = self.map { $0 }
        
        try container.encode(elements, forKey: .storage)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let elements = try container.decode(Array<Element>.self, forKey: .storage)
        guard !elements.isEmpty else { return }
        
        self.storage = CircularBuffer(elements: elements)
    }
    
}

// MARK: CustomStringConvertible and CustomDebugStringConvertible conformances
extension Deque: CustomStringConvertible, CustomDebugStringConvertible {
    private func makeDescription(debug: Bool) -> String {
            var result = debug ? "\(String(reflecting: Deque.self))([" : "Deque["
            var first = true
            for item in self {
                if first {
                    first = false
                } else {
                    result += ", "
                }
                if debug {
                    debugPrint(item, terminator: "", to: &result)
                }
                else {
                    print(item, terminator: "", to: &result)
                }
            }
            result += debug ? "])" : "]"
            return result
        }

    public var description: String {
        return makeDescription(debug: false)
    }
    
    public var debugDescription: String {
        return makeDescription(debug: true)
    }
    
}

// MARK: - Private Interface
// MARK: - Copy on write helpers
extension Deque {
    @inline(__always)
    private var _isUnique: Bool {
        mutating get {
            isKnownUniquelyReferenced(&storage)
        }
    }
    
    @inline(__always)
    private mutating func _makeUnique(additionalCapacity: Int = 0) {
        if self.storage == nil {
            self.storage = CircularBuffer(capacity: additionalCapacity)
        } else if !_isUnique {
            storage = storage!.copy(additionalCapacity: additionalCapacity)
        } else if additionalCapacity > 0 {
            storage!.allocateAdditionalCapacity(additionalCapacity)
        }
    }
    
    @inline(__always)
    mutating private func _checkForEmptyAtEndOfMutation() {
        if self.storage?.count == 0 {
            self.storage = nil
        }
    }
    
}
