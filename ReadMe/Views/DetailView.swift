//
//  DetailView.swift
//  ReadMe
//
//  Created by bogdanov on 16.06.21.
//

import SwiftUI

struct DetailView: View {
    @ObservedObject var book: Book
    @EnvironmentObject var library: Library

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                BookmarkButton(book: book)
                TitleAndAuthorStack(book: book, titleFont: .title, authorFont: .title2)
            }
            Spacer()
                .frame(height: 24)
            ReviewAndImageStack(book: book, image: $library.uiImages[book])
            Spacer()
        }
        .padding()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(book: .init())
            .environmentObject(Library())
            .previewedInAllColorSchemes
    }
}
