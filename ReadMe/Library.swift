//
//  Library.swift
//  ReadMe
//
//  Created by bogdanov on 16.06.21.
//

import Combine
import SwiftUI
import class UIKit.UIImage

enum Section: CaseIterable {
    case readMe
    case finished
}

enum SortStyle: CaseIterable {
    case title
    case author
    case manual
}

final class Library: ObservableObject {
    @Published var sortStyle: SortStyle = .manual

    /// The books are sorted by its `sortStyle`.
    var sortedBooks: [Book] {
        get {
            switch sortStyle {
            case .title:
                return booksCache.sorted {
                    ["a ", "the "].reduce($0.title.lowercased()) { title, article in
                        title.without(prefix: article) ?? title
                    }
                }
            case .author:
                return booksCache.sorted {
                    PersonNameComponentsFormatter().personNameComponents(from: $0.author) ?? .init()
                }
            case .manual:
                return booksCache
            }
        }
        set {
            booksCache.removeAll { book in
                !newValue.contains(book)
            }
        }
    }

    var manuallySortedBooks: [Section: [Book]] {
        get {
            Dictionary(grouping: booksCache, by: \.readMe)
                .mapKeys(Section.init)
        }
        set {
            booksCache = newValue
                .sorted { $1.key == .finished }
                .flatMap { $0.value }
        }
    }

    /// Add a new book at the start of the library's manually-sorted books.
    func addNewBook(_ book: Book, image: UIImage?) {
        booksCache.insert(book, at: 0)
        uiImages[book] = image
        storeCancellable(for: book)
    }

    func deleteBooks(atOffsets offsets: IndexSet, section: Section?) {
        let booksBeforeDeletion = booksCache

        if let section = section {
            manuallySortedBooks[section]?.remove(atOffsets: offsets)
        } else {
            sortedBooks.remove(atOffsets: offsets)
        }

        for change in booksCache.difference(from: booksBeforeDeletion) {
            if case let .remove(_, deletedBook, _) = change {
                uiImages[deletedBook] = nil
            }
        }
    }

    func moveBooks(oldOffsets: IndexSet, newOffset: Int, section: Section) {
        manuallySortedBooks[section]?.move(fromOffsets: oldOffsets, toOffset: newOffset)
    }

    init(books: [Book] = []) {
        booksCache = books
        booksCache.forEach(storeCancellable)
    }

    @Published var uiImages: [Book: UIImage] = [:]

    @Published private var booksCache: [Book]

    /// Forwards individual book changes to be considered Library changes.
    private var cancellable: Set<AnyCancellable> = []
}

// MARK: - PersonNameComponents: Comparable

extension PersonNameComponents: Comparable {
    public static func < (components0: Self, components1: Self) -> Bool {
        var fallback: Bool {
            [\PersonNameComponents.givenName, \.middleName].contains {
                Optional(
                    optionals: (components0[keyPath: $0], components1[keyPath: $0])
                )
                .map { $0.lowercased().isLessThan($1.lowercased(), whenEqual: false) }
                ?? false
            }
        }

        switch (
            components0.givenName?.lowercased(), components0.familyName?.lowercased(),
            components1.givenName?.lowercased(), components1.familyName?.lowercased()
        ) {
        case let (
            _, familyName0?,
            _, familyName1?
        ):
            return familyName0.isLessThan(familyName1, whenEqual: fallback)
        case (
            _, let familyName0?,
            let givenName1?, nil
        ):
            return familyName0.isLessThan(givenName1, whenEqual: fallback)
        case (
            let givenName0?, nil,
            _, let familyName1?
        ):
            return givenName0.isLessThan(familyName1, whenEqual: fallback)
        default:
            return fallback
        }
    }
}

// MARK: - private

private extension Optional {
    /// Exchange two optionals for a single optional tuple.
    /// - Returns: `nil` if either tuple element is `nil`.
    init<Wrapped0, Wrapped1>(optionals: (Wrapped0?, Wrapped1?))
        where Wrapped == (Wrapped0, Wrapped1)
    {
        switch optionals {
        case let (wrapped0?, wrapped1?):
            self = (wrapped0, wrapped1)
        default:
            self = nil
        }
    }
}

private extension Comparable {
    /// Like `<`, but with a default for the case when `==` evaluates to `true`.
    func isLessThan(
        _ comparable: Self,
        whenEqual default: @autoclosure () -> Bool
    ) -> Bool {
        self == comparable
            ? `default`()
            : self < comparable
    }
}

private extension Library {
    func storeCancellable(for book: Book) {
        book.$readMe.sink { [unowned self] _ in
            objectWillChange.send()
        }
        .store(in: &cancellable)
    }
}

private extension Section {
    init(readMe: Bool) {
        self = readMe ? .readMe : .finished
    }
}

private extension Dictionary {
    /// Same values, corresponding to `map`ped keys.
    ///
    /// - Parameter transform: Accepts each key of the dictionary as its parameter
    ///   and returns a key for the new dictionary.
    /// - Postcondition: The collection of transformed keys must not contain duplicates.
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed) rethrows -> [Transformed: Value] {
        .init(uniqueKeysWithValues: try map { (try transform($0.key), $0.value) })
    }
}

private extension Sequence {
    /// Sorted by a common `Comparable` value.
    func sorted<Comparable: Swift.Comparable>(
        _ comparable: (Element) throws -> Comparable
    ) rethrows -> [Element] {
        try sorted(comparable, <)
    }

    /// Sorted by a common `Comparable` value, and sorting closure.
    func sorted<Comparable: Swift.Comparable>(
        _ comparable: (Element) throws -> Comparable,
        _ areInIncreasingOrder: (Comparable, Comparable) throws -> Bool
    ) rethrows -> [Element] {
        try sorted {
            try areInIncreasingOrder(comparable($0), comparable($1))
        }
    }
}

private extension String {
    /// - Returns: nil if not prefixed with `prefix`
    func without(prefix: String) -> Self? {
        guard hasPrefix(prefix)
        else { return nil }

        return .init(dropFirst(prefix.count))
    }
}
