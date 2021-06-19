//
//  ReviewAndImageStack.swift
//  ReadMe
//
//  Created by bogdanov on 19.06.21.
//

import class PhotosUI.PHPickerViewController
import SwiftUI

struct ReviewAndImageStack: View {
    @ObservedObject var book: Book
    @Binding var image: UIImage?
    @State var showingImagePicker = false
    @State var showingDeleteImageAlert = false

    var body: some View {
        let updateButton = Button(action: {
            showingImagePicker = true
        }, label: {
            Text("Update Image...")
        })

        let deleteButton = Button(action: {
            showingDeleteImageAlert = true
        }, label: {
            Text("Delete image")
                .foregroundColor(.red)
        })

        VStack {
            TextField("Review...", text: $book.microReview)
            Book.Image(uiImage: image, title: book.title, cornerRadius: 16)
                .scaledToFit()
            if image != nil {
                HStack {
                    Spacer()
                    updateButton
                    Spacer()
                    deleteButton
                    Spacer()
                }
            } else {
                updateButton
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PHPickerViewController.View(image: $image)
        }
        .alert(isPresented: $showingDeleteImageAlert) {
            .init(
                title: .init("Delete image for \(book.title)?"),
                primaryButton: .destructive(.init("Delete")) {
                    image = nil
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ReviewAndImageStack_Previews: PreviewProvider {
    static var previews: some View {
        ReviewAndImageStack(book: .init(), image: .constant(nil))
            .padding(.horizontal)
            .previewedInAllColorSchemes
    }
}
