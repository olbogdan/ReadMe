//
//  Library.swift
//  ReadMe
//
//  Created by bogdanov on 16.06.21.
//

import Combine
import class UIKit.UIImage

class Library: ObservableObject {
    var sortedBooks: [Book] { booksCache }

    private var booksCache: [Book] = [
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

    @Published var uiImages: [Book: UIImage] = [:]
}
