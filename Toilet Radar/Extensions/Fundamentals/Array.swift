//
//  Array.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 19.03.2023.
//

extension Array {
    func filterKeepingFirstAndLast(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        return try enumerated().filter {
            try isIncluded($0.element) || $0.offset == 0 || $0.offset == indices.last
        }.map { $0.element }
    }
    
    func splitExceptAtStartAndEnd(maxSplits: Int = .max, omittingEmptySubsequences: Bool = true, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [ArraySlice<Element>] {
        return try enumerated().split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences) {
            try isSeparator($0.element) || $0.offset == 0 || $0.offset == indices.last
        }.map { $0.map { $0.element }.suffix(from: 0) }
    }
}
