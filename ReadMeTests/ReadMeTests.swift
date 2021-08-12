//
//  ReadMeTests.swift
//  ReadMeTests
//
//  Created by Oleksndr Bogdanov on 12.08.21.
//

import XCTest
@testable import ReadMe

class ReadMeTests: XCTestCase {

    func test_addNewBook_shouldAddABook() throws {
        let library = Library()
        library.addNewBook(Book(), image: nil)
        XCTAssertEqual(library.sortedBooks.count, 1)
    }
}
