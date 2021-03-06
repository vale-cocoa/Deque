# Deque

A double ended queue, that is a queue which allows access to its both ends with an amortized O(1) complexity.

 `Deque` is an ordered, random-access collection, it basically presents the same interface and behavior of an array (including value semantics), but with the advantage of an amortized O(1) complexity for operations on the first position of its storage, rather than O(*n*) as arrays do.
 A `Deque` is a *FIFO* (first in, first out) queue, thus it'll dequeue elements respecting the order in which they were enqeueued before.
