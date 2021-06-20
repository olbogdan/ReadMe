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

final class Library: ObservableObject {
    var sortedBooks: [Book] {
        get {
            booksCache
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
            if case .remove(_, let deletedBook, _) = change {
                uiImages[deletedBook] = nil
            }
        }
    }

    func moveBooks(oldOffsets: IndexSet, newOffset: Int, section: Section) {
        manuallySortedBooks[section]?.move(fromOffsets: oldOffsets, toOffset: newOffset)
    }

    init() {
        booksCache.forEach(storeCancellable)
    }

    @Published var uiImages: [Book: UIImage] = [:]

    @Published private var booksCache: [Book] = [
        .init(title: "War and Peace", author: "Leo Tolstoy", microReview: "describes oak on 5 pages"),
        .init(title: "Anna Karenina", author: "Leo Tolstoy"),
        .init(title: "Crime and Punishment", author: "Fyodor Dostoevsky"),
        .init(title: "The Master and Margarita", author: "Mikhail Bulgakov", microReview: "my favourite"),
        .init(title: "Life and Fate", author: "Vasily Grossman"),
        .init(title: "The Brothers Karamazov and Magic Sword", author: "Fyodor Dostoevsky"),
        .init(title: "Dead Souls", author: "Nikolai Gogol"),
        .init(title: "Eugene Onegin", author: "Aleksandr Pushkin"),
        .init(title: "Lolita", author: "Vladimir Nabokov"),
        .init(title: "Doctor Zhivago", author: "Boris Pasternak")
    ]

    /// Forwards individual book changes to be considered Library changes.
    private var cancellable: Set<AnyCancellable> = []
}

// MARK: - private

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
