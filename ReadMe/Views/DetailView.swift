//
//  DetailView.swift
//  ReadMe
//
//  Created by bogdanov on 16.06.21.
//

import class PhotosUI.PHPickerViewController
import SwiftUI

struct DetailView: View {
    let book: Book
    @Binding var image: UIImage?
    @State var showImagePicker = false

    var body: some View {
        VStack(alignment: .leading) {
            TitleAndAuthorStack(book: book, titleFont: .title, authorFont: .title2)
            VStack {
                Book.Image(uiImage: image, title: book.title, cornerRadius: 16)
                    .scaledToFit()
                Button(action: {
                    showImagePicker = true
                }, label: {
                    Text("Update Image...")
                })
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            PHPickerViewController.View(image: $image)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(book: .init(), image: .constant(nil))
            .previewedInAllColorSchemes
    }
}
