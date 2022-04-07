//
//  SectionsHelperTests.swift
//  
//
//  Created by Jacob Sikorski on 2022-04-06.
//

import XCTest
import Canoe

class SectionsHelperTests: XCTestCase {
    struct Row: SectionsHelperIdentifiable {
        let id: UUID
        let uuid = UUID()
    }

    struct Section: SectionsHelperSection, SectionsHelperIdentifiable {
        let id: UUID
        var rows: [Row]
    }

    private var sectionsHelper: SectionsHelper<Section> = SectionsHelper()

    func testSetSections() {
        // Given
        let sections = makeSections(count: 10, rowsCount: 10)

        // When
        sectionsHelper.set(sections: sections)

        // Then
        XCTAssertEqual(sectionsHelper.sections.count, 10)
        XCTAssertEqual(sectionsHelper.sections.last?.rows.count, 10)
    }

    func testSectionForIndexPath() {
        // Given
        let indexPath = IndexPath(row: 10, section: 5)
        let sections = makeSections(count: 10, rowsCount: 10)
        sectionsHelper.set(sections: sections)

        // When
        let section = sectionsHelper.section(for: indexPath)

        // Then
        XCTAssertEqual(sections[5].id, section.id)
        XCTAssertEqual(sectionsHelper.sections[5].id, section.id)
    }

    func testSectionsWhere() {
        // Given
        let indexSet = IndexSet([0, 2, 5, 99])
        let sections = makeSections(count: 10, rowsCount: 10)
        sectionsHelper.set(sections: sections)

        // When
        let retrievedSections = sectionsHelper.sections { index, _ in
            return indexSet.contains(index)
        }

        XCTAssertEqual(retrievedSections.count, 3)

        // Then
        XCTAssertEqual(sections[0].id, retrievedSections[0].id)
        XCTAssertEqual(sections[2].id, retrievedSections[1].id)
        XCTAssertEqual(sections[5].id, retrievedSections[2].id)
    }

    func testSectionsForIndexPaths() {
        // Given
        let indexPaths = [
            IndexPath(row: 10, section: 0),
            IndexPath(row: 10, section: 2),
            IndexPath(row: 9, section: 5),
            IndexPath(row: 8, section: 5),
            IndexPath(row: 7, section: 5),
        ]
        let sections = makeSections(count: 10, rowsCount: 10)
        sectionsHelper.set(sections: sections)

        // When
        let retrievedSections = sectionsHelper.sections(for: indexPaths)
        XCTAssertEqual(retrievedSections.count, 3)

        // Then
        XCTAssertEqual(sections[0].id, retrievedSections[0].id)
        XCTAssertEqual(sections[2].id, retrievedSections[1].id)
        XCTAssertEqual(sections[5].id, retrievedSections[2].id)
    }

    func testSectionsForIndexSet() {
        // Given
        let indexSet = IndexSet([0, 2, 5, 99])
        let sections = makeSections(count: 10, rowsCount: 10)
        sectionsHelper.set(sections: sections)

        // When
        let retrievedSections = sectionsHelper.sections(for: indexSet)
        XCTAssertEqual(retrievedSections.count, 3)

        // Then
        XCTAssertEqual(sections[0].id, retrievedSections[0].id)
        XCTAssertEqual(sections[2].id, retrievedSections[1].id)
        XCTAssertEqual(sections[5].id, retrievedSections[2].id)
    }

    func testFirstSectionWhere() {
        // Given
        let indexSet = IndexSet([99, 5])
        let sections = makeSections(count: 10, rowsCount: 10)
        sectionsHelper.set(sections: sections)

        // When
        let section = sectionsHelper.firstSection { index, _ in
            return indexSet.contains(index)
        }

        // Then
        XCTAssertEqual(sections[5].id, section?.id)
        XCTAssertEqual(sectionsHelper.sections[5].id, section?.id)
    }

    func testSectionIndexesWhere() {
        let indexSet = IndexSet([99, 1, 5])
        let sections = makeSections(count: 10, rowsCount: 10)
        sectionsHelper.set(sections: sections)

        // When
        let givenIndexSet = sectionsHelper.sectionIndexes { index, _ in
            return indexSet.contains(index)
        }

        // Then
        XCTAssertEqual(givenIndexSet, IndexSet([1, 5]))
    }

    func testFirstSectionIndexWhere() {
        let indexSet = IndexSet([99, 5, 1])
        let sections = makeSections(count: 10, rowsCount: 10)
        sectionsHelper.set(sections: sections)

        // When
        let index = sectionsHelper.firstSectionIndex { index, _ in
            return indexSet.contains(index)
        }

        // Then
        XCTAssertEqual(index, 1)
    }

    func testInsertSectionAtIndex() {
        let sections = makeSections(count: 10, rowsCount: 10)
        let section = makeSection(rowsCount: 5)
        sectionsHelper.set(sections: sections)

        // When
        let indexSet = sectionsHelper.insert(section: section, at: 5)

        // Then
        XCTAssertEqual(indexSet, IndexSet([5]))
        XCTAssertEqual(sectionsHelper.sections[5].id, section.id)
        XCTAssertEqual(sectionsHelper.sections[5].rows.count, 5)
    }

    func testInsertSectionsStartingAtIndex() {
        let sections = makeSections(count: 10, rowsCount: 10)
        let addedSections = makeSections(count: 5, rowsCount: 5)
        sectionsHelper.set(sections: sections)

        // When
        let indexSet = sectionsHelper.insert(sections: addedSections, startingAt: 5)

        // Then
        XCTAssertEqual(indexSet, IndexSet([5, 6, 7, 8, 9]))
        XCTAssertEqual(sectionsHelper.sections[4].id, sections[4].id)
        XCTAssertEqual(sectionsHelper.sections[5].id, addedSections[0].id)
        XCTAssertEqual(sectionsHelper.sections[6].id, addedSections[1].id)
        XCTAssertEqual(sectionsHelper.sections[7].id, addedSections[2].id)
        XCTAssertEqual(sectionsHelper.sections[8].id, addedSections[3].id)
        XCTAssertEqual(sectionsHelper.sections[9].id, addedSections[4].id)
        XCTAssertEqual(sectionsHelper.sections[10].id, sections[5].id)
    }

    func testReplaceSectionAtIndex() {
        let sections = makeSections(count: 10, rowsCount: 10)
        let section = makeSection(rowsCount: 5)
        sectionsHelper.set(sections: sections)

        // When
        let indexSet = sectionsHelper.replace(section: section, at: 5)

        // Then
        XCTAssertEqual(indexSet, IndexSet([5]))
        XCTAssertEqual(sectionsHelper.sections[5].id, section.id)
        XCTAssertEqual(sectionsHelper.sections[5].rows.count, 5)
    }

    func testReplaceSectionsWhere() {
        let sections = makeSections(count: 10, rowsCount: 10)
        let section = makeSection(rowsCount: 5)
        sectionsHelper.set(sections: sections)

        // When
        let indexSet = sectionsHelper.replaceSections { index, _ in
            guard index == 5 else { return nil }
            return section
        }

        // Then
        XCTAssertEqual(indexSet, IndexSet([5]))
        XCTAssertEqual(sectionsHelper.sections[5].id, section.id)
        XCTAssertEqual(sectionsHelper.sections[5].rows.count, 5)
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
