//
//  CategoryTests.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

@testable import Exhbt
import XCTest

final class CategoryTests: XCTestCase {

    func testCategoryAttributes() throws {
        let category = Category.beauty
        
        XCTAssertEqual(category.image, "BeautyCategory")
        XCTAssertEqual(category.title, "Beauty")
        XCTAssertEqual(category.id, 3)
    }

    func testCategoryDisplayableList() throws {
        let list = Category.displayableList
        
        XCTAssertEqual(list.first, .all)
        XCTAssertEqual(list.last, .sports)
    }
}
