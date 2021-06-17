//
//  PHPickerViewController.swift
//  ReadMe
//
//  Created by bogdanov on 17.06.21.
//

import PhotosUI
import SwiftUI

extension PHPickerViewController {
    struct View {
        @Binding var image: UIImage?
    }
}

extension PHPickerViewController.View: UIViewControllerRepresentable {
    func makeCoordinator() -> some PHPickerViewControllerDelegate {
        PHPickerViewController.Delegate(image: $image)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let picker = PHPickerViewController(configuration: .init())
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}

extension PHPickerViewController.Delegate: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            DispatchQueue.main.async { self.image = image as? UIImage }
        }

        picker.dismiss(animated: true)
    }
}

private extension PHPickerViewController {
    final class Delegate {
        @Binding var image: UIImage?

        init(image: Binding<UIImage?>) {
            _image = image
        }
    }
}
