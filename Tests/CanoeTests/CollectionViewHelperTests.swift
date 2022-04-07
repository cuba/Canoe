//
//  CollectionViewHelperTests.swift
//  
//
//  Created by Jacob Sikorski on 2022-04-06.
//

import XCTest
import Canoe

class CollectionViewHelperTests: XCTestCase {
    struct Row: SectionsHelperIdentifiable {
        let id: UUID
        let uuid = UUID()
    }

    struct Section: SectionsHelperSection, SectionsHelperIdentifiable {
        let id: UUID
        var rows: [Row]
    }

    private var collectionViewHelper: CollectionViewHelper<Section> = CollectionViewHelper(collectionView: UICollectionView(frame: .zero, collectionViewLayout: .init()))

    func testShowSections() {
        // Given
        let sections = makeSections(count: 10, rowsCount: 10)

        // When
        collectionViewHelper.show(sections: sections)

        // Then
        XCTAssertEqual(collectionViewHelper.sectionsHelper.sections.count, 10)
        XCTAssertEqual(collectionViewHelper.sectionsHelper.sections.last?.rows.count, 10)
    }

    func testSectionForIndexPath() {
        // Given
        let indexPath = IndexPath(row: 10, section: 5)
        let sections = makeSections(count: 10, rowsCount: 10)
        collectionViewHelper.show(sections: sections)

        // When
        let section = collectionViewHelper.sectionsHelper.section(for: indexPath)

        // Then
        XCTAssertEqual(sections[5].id, section.id)
        XCTAssertEqual(collectionViewHelper.sectionsHelper.sections[5].id, section.id)
    }

    // MARK: - Helper methods

    private func makeRows(count: UInt) -> [Row] {
        return (0..<count).map { index -> Row in
            return makeRow()
        }
    }

    private func makeRow() -> Row {
        return Row(id: UUID())
    }

    private func makeSections(count: UInt, rowsCount: UInt) -> [Section] {
        return (0..<count).map { _ -> Section in
            return makeSection(rowsCount: rowsCount)
        }
    }

    private func makeSection(rowsCount: UInt) -> Section {
        let rows = makeRows(count: rowsCount)
        return Section(id: UUID(), rows: rows)
    }
}
