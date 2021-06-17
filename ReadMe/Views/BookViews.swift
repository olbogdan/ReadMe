//
//  BookViews.swift
//  ReadMe
//
//  Created by bogdanov on 16.06.21.
//

import SwiftUI

extension Book {
    struct Image: View {
        let uiImage: UIImage?
        let title: String
        var size: CGFloat?
        let cornerRadius: CGFloat

        var body: some View {
            if let image = uiImage.map(SwiftUI.Image.init) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .cornerRadius(cornerRadius)
            } else {
                let symbol = SwiftUI.Image(title: title) ?? .init(systemName: "book")
                symbol
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .font(.title.weight(.light))
                    .foregroundColor(.secondary)
            }
        }
    }
}

extension Image {
    init?(title: String) {
        guard let character = title.first,
              case let symbolName = "\(character.lowercased()).square",
              UIImage(systemName: symbolName) != nil
        else {
            return nil
        }
        self.init(systemName: symbolName)
    }
}

struct TitleAndAuthorStack: View {
    let book: Book
    let titleFont: Font
    let authorFont: Font

    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
                .font(titleFont)
            Text(book.author)
                .font(authorFont)
                .foregroundColor(.secondary)
        }
    }
}

extension View {
    var previewedInAllColorSchemes: some View {
        ForEach(ColorScheme.allCases, id: \.self, content: preferredColorScheme)
    }
}

struct Book_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitleAndAuthorStack(book: .init(), titleFont: .title, authorFont: .title2)
            Book.Image(uiImage: nil, title: Book().title, cornerRadius: 0)
            Book.Image(uiImage: nil, title: "", cornerRadius: 0)
            Book.Image(uiImage: nil, title: "🎪", cornerRadius: 0)
        }.previewedInAllColorSchemes
    }
}
