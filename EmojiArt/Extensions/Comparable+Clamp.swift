// Extensions/Comparable+Clamp.swift

/// It adds a helper to clamp any comparable value into a closed range.

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
