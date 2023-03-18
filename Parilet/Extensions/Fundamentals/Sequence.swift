//
//  Sequence.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 11.03.2023.
//

extension Sequence where Element: Hashable {
    /// Returns true if no element is equal to any other element.
    func isDistinct() -> Bool {
        var set = Set<Element>()
        for element in self {
            if set.insert(element).inserted == false { return false }
        }
        return true
    }
}
