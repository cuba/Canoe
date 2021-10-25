import XCTest
import UIKit
@testable import Canoe

final class TableViewHelperTests: XCTestCase {
    struct Row: TableViewHelperIdentifiable {
        let id: UUID
        let uuid = UUID()
    }
    
    struct Section: TableViewHelperSection, TableViewHelperIdentifiable {
        let id: UUID
        var rows: [Row]
    }
    
    private var tableViewHelper: TableViewHelper<Section> = TableViewHelper(tableView: UITableView())

    override func setUpWithError() throws {
        let tableView = UITableView()
        tableViewHelper = TableViewHelper<Section>(tableView: tableView)
        tableViewHelper.tableView.dataSource = self
    }
    
    // MARK: - Show
    
    func testShowSection() {
        // Given
        let section = makeSection(rowsCount: 100)
        
        // When
        tableViewHelper.show(section: section)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 1)
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 100)
    }
    
    func testShowSections() {
        // Given
        let sections = makeSections(count: 100, rowsCount: 10)
        
        // When
        tableViewHelper.show(sections: sections)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 100)
        XCTAssertEqual(tableViewHelper.sections.last?.rows.count, 10)
    }
    
    // MARK: - Sections
    
    func testSectionForIndexPath() {
        // Given
        let indexPath = IndexPath(row: 9999999, section: 5)
        let sections = makeSections(count: 100, rowsCount: 10)
        tableViewHelper.show(sections: sections)
        
        // When
        let section = tableViewHelper.section(for: indexPath)
        
        // Then
        XCTAssertEqual(sections[5].id, section.id)
        XCTAssertEqual(tableViewHelper.sections[5].id, section.id)
    }
    
    func testInsertSectionAtIndex() {
        // Given
        tableViewHelper.show(sections: makeSections(count: 100, rowsCount: 1))
        let previousSection = tableViewHelper.sections[5]
        
        // When
        let section = makeSection(rowsCount: 1)
        tableViewHelper.insert(section: section, at: 5, with: .automatic)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[5].id, section.id)
        XCTAssertEqual(tableViewHelper.sections[6].id, previousSection.id)
        XCTAssertEqual(tableViewHelper.sections.count, 101)
    }
    
    func testInsertSectionsStartingAt() {
        // Given
        let sections = makeSections(count: 5, rowsCount: 1)
        tableViewHelper.show(sections: sections)
        
        // When
        let newSections = makeSections(count: 5, rowsCount: 1)
        tableViewHelper.insert(sections: newSections, startingAt: 4, with: .automatic)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 10)
        XCTAssertEqual(tableViewHelper.sections[4].id, newSections[0].id)
        XCTAssertEqual(tableViewHelper.sections[5].id, newSections[1].id)
        XCTAssertEqual(tableViewHelper.sections[6].id, newSections[2].id)
        XCTAssertEqual(tableViewHelper.sections[7].id, newSections[3].id)
        XCTAssertEqual(tableViewHelper.sections[8].id, newSections[4].id)
        XCTAssertEqual(tableViewHelper.sections[9].id, sections[4].id)
    }
    
    func testReplaceSectionAtIndex() {
        // Given
        tableViewHelper.show(sections: makeSections(count: 100, rowsCount: 1))
        let previousSection = tableViewHelper.sections[5]
        
        // When
        let section = makeSection(rowsCount: 1)
        tableViewHelper.replace(section: section, at: 5)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[5].id, section.id)
        XCTAssertNotEqual(tableViewHelper.sections[6].id, previousSection.id)
        XCTAssertEqual(tableViewHelper.sections.count, 100)
    }
    
    func testReplaceSectionsWhere() {
        // Given
        let sections = makeSections(count: 100, rowsCount: 100)
        let testIndexes = [0, 1, 98, 99]
        let previousSections = testIndexes.map({ sections[$0] })
        tableViewHelper.show(sections: sections)
        var newSections: [Section] = []
        
        // When
        tableViewHelper.replaceSections { oldSection in
            guard previousSections.contains(where: { oldSection.id == $0.id }) else { return nil }
            let section = makeSection(rowsCount: 50)
            newSections.append(section)
            return section
        }
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 100)
        
        for (newIndex, oldIndex) in testIndexes.enumerated() {
            XCTAssertEqual(tableViewHelper.sections[oldIndex].id, newSections[newIndex].id)
        }
    }
    
    func testRemoveSectionAtIndex() {
        // Given
        let sections = makeSections(count: 100, rowsCount: 100)
        tableViewHelper.show(sections: sections)
        
        // When
        tableViewHelper.removeSection(at: 5)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 99)
        XCTAssertEqual(tableViewHelper.sections[4].id, sections[4].id)
        XCTAssertEqual(tableViewHelper.sections[5].id, sections[6].id)
        XCTAssertEqual(tableViewHelper.sections[98].id, sections[99].id)
    }
    
    func testRemoveSectionsWhere() {
        // Given
        let sections = makeSections(count: 100, rowsCount: 100)
        let testIndexes = [0, 1, 50, 51, 98, 99]
        let previousSections = testIndexes.map({ sections[$0] })
        tableViewHelper.show(sections: sections)
        
        // When
        tableViewHelper.removeSections(with: .automatic) { oldSection in
            return previousSections.contains(where: { oldSection.id == $0.id })
        }
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 100 - testIndexes.count)
        XCTAssertEqual(tableViewHelper.sections[0].id, sections[2].id)
        XCTAssertEqual(tableViewHelper.sections[48].id, sections[52].id)
        XCTAssertEqual(tableViewHelper.sections[93].id, sections[97].id)
    }
    
    // MARK: - Rows
    
    func testRowForIndexPath() {
        // Given
        let indexPath = IndexPath(row: 5, section: 5)
        let sections = makeSections(count: 100, rowsCount: 10)
        tableViewHelper.show(sections: sections)
        
        // When
        let row = tableViewHelper.row(for: indexPath)
        
        // Then
        XCTAssertEqual(sections[5].rows[5].id, row.id)
        XCTAssertEqual(tableViewHelper.sections[5].rows[5].id, row.id)
    }
    
    func testInsertRowAtIndexPath() {
        // Given
        let sections = makeSections(count: 1, rowsCount: 100)
        tableViewHelper.show(sections: sections)
        let indexPath = IndexPath(row: 5, section: 0)
        let newRow = makeRow()
        
        // When
        tableViewHelper.insert(row: newRow, at: indexPath)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 101)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, newRow.id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[6].id, sections[0].rows[5].id)
    }
    
    func testInsertRowsStartingAtIndexPath() {
        // Given
        let sections = makeSections(count: 1, rowsCount: 6)
        tableViewHelper.show(sections: sections)
        let indexPath = IndexPath(row: 5, section: 0)
        let newRows = makeRows(count: 5)
        
        // When
        tableViewHelper.insert(rows: newRows, startingAt: indexPath)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 11)
        XCTAssertEqual(tableViewHelper.sections[0].rows[4].id, sections[0].rows[4].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, newRows[0].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[6].id, newRows[1].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[7].id, newRows[2].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[8].id, newRows[3].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[9].id, newRows[4].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[10].id, sections[0].rows[5].id)
    }
    
    func testAppendRowsToSectionAt() {
        // Given
        let sections = makeSections(count: 1, rowsCount: 5)
        tableViewHelper.show(sections: sections)
        let newRows = makeRows(count: 5)
        
        // When
        tableViewHelper.append(rows: newRows, toSectionAt: 0)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 10)
        XCTAssertEqual(tableViewHelper.sections[0].rows[4].id, sections[0].rows[4].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, newRows[0].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[6].id, newRows[1].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[7].id, newRows[2].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[8].id, newRows[3].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[9].id, newRows[4].id)
    }
    
    func testInsertRowsWhere() {
        // Given
        let section = makeSection(rowsCount: 100)
        let testIndexes = [0, 1, 50, 51, 98, 99]
        let previousRows = testIndexes.map({ section.rows[$0] })
        var newRows: [Row] = []
        tableViewHelper.show(section: section)
        
        // When
        tableViewHelper.insertRows(with: .automatic) { oldSection, oldRow in
            guard previousRows.contains(where: { oldRow.id == $0.id }) else {
                return nil
            }
            
            let beforeRow = makeRow()
            let afterRow = makeRow()
            newRows.append(beforeRow)
            newRows.append(afterRow)
            return (before: [beforeRow], after: [afterRow])
        }
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 1)
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 100 + newRows.count)
        XCTAssertEqual(tableViewHelper.sections[0].rows[0].id, newRows[0].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[1].id, section.rows[0].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[2].id, newRows[1].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[3].id, newRows[2].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[4].id, section.rows[1].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, newRows[3].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[6].id, section.rows[2].id)
        
        // We added 4 before that. 50 + 4 = 54
        XCTAssertEqual(tableViewHelper.sections[0].rows[54].id, newRows[4].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[55].id, section.rows[50].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[56].id, newRows[5].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[57].id, newRows[6].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[58].id, section.rows[51].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[59].id, newRows[7].id)
        
        // We added 8 before that. 98 + 8 = 106
        XCTAssertEqual(tableViewHelper.sections[0].rows[106].id, newRows[8].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[107].id, section.rows[98].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[108].id, newRows[9].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[109].id, newRows[10].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[110].id, section.rows[99].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[111].id, newRows[11].id)
    }
    
    func testReplaceRowAtIndexPath() {
        // Given
        let section = makeSection(rowsCount: 100)
        tableViewHelper.show(section: section)
        let indexPath = IndexPath(row: 5, section: 0)
        let newRow = makeRow()
        
        // When
        tableViewHelper.replace(row: newRow, at: indexPath, reloadCell: true)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 100)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, newRow.id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[6].id, section.rows[6].id)
    }
    
    func testReplaceRowsWhere() {
        // Given
        let section = makeSection(rowsCount: 100)
        let testIndexes = [0, 1, 98, 99]
        let previousRows = testIndexes.map({ section.rows[$0] })
        tableViewHelper.show(section: section)
        var newRows: [Row] = []
        
        // When
        tableViewHelper.replaceRows(with: .automatic) { oldSection, oldRow in
            guard previousRows.contains(where: { oldRow.id == $0.id }) else { return nil }
            let row = makeRow()
            newRows.append(row)
            return row
        }
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 1)
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 100)
        
        for (newIndex, oldIndex) in testIndexes.enumerated() {
            XCTAssertEqual(tableViewHelper.sections[0].rows[oldIndex].id, newRows[newIndex].id)
        }
    }
    
    func testRemoveRowAtIndexPath() {
        // Given
        let section = makeSection(rowsCount: 100)
        let indexPath = IndexPath(row: 5, section: 0)
        tableViewHelper.show(section: section)
        
        // When
        tableViewHelper.removeRow(at: indexPath)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 1)
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 99)
        XCTAssertEqual(tableViewHelper.sections[0].rows[4].id, section.rows[4].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, section.rows[6].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[98].id, section.rows[99].id)
    }
    
    func testRemoveRowsAtIndexPaths() {
        // Given
        let sections = makeSections(count: 10, rowsCount: 10)
        
        let indexPaths = [
            IndexPath(row: 5, section: 0),
            IndexPath(row: 1, section: 0),
            IndexPath(row: 2, section: 0)
        ]
        
        tableViewHelper.show(sections: sections)
        
        // When
        tableViewHelper.removeRows(at: indexPaths)
        
        // Then
        // Initial [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        // Initial [A, B, C, D, E, F, G, H, I. J]
        // Results [A, D, E, G, H, I. J]
        // Removed [B, C, F]
        XCTAssertEqual(tableViewHelper.sections.count, 10)
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 7)
        XCTAssertEqual(tableViewHelper.sections[0].rows[0].id, sections[0].rows[0].id) // A
        XCTAssertEqual(tableViewHelper.sections[0].rows[1].id, sections[0].rows[3].id) // D
        XCTAssertEqual(tableViewHelper.sections[0].rows[4].id, sections[0].rows[7].id) // H
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, sections[0].rows[8].id) // I
    }
    
    func testRemoveRowsWhere() {
        // Given
        let section = makeSection(rowsCount: 100)
        let testIndexes = [0, 1, 50, 51, 98, 99]
        let previousRows = testIndexes.map({ section.rows[$0] })
        tableViewHelper.show(section: section)
        
        // When
        tableViewHelper.removeRows(with: .automatic) { _, oldRow in
            return previousRows.contains(where: { oldRow.id == $0.id })
        }
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 1)
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 100 - testIndexes.count)
        XCTAssertEqual(tableViewHelper.sections[0].rows[0].id, section.rows[2].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[48].id, section.rows[52].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[93].id, section.rows[97].id)
    }
    
    // MARK: Identifiable Section
    
    func testReplaceIdentifiableSections() {
        // Given
        let sections = makeSections(count: 100, rowsCount: 100)
        let testIndexes = [0, 1, 98, 99]
        let previousSections = testIndexes.map({ sections[$0] })
        let newSections = previousSections.map({ Section(id: $0.id, rows: makeRows(count: 1)) })
        tableViewHelper.show(sections: sections)
        
        // When
        tableViewHelper.replace(sections: newSections, with: .automatic)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 100)
        
        for (newIndex, oldIndex) in testIndexes.enumerated() {
            XCTAssertEqual(tableViewHelper.sections[oldIndex].id, newSections[newIndex].id)
            XCTAssertEqual(tableViewHelper.sections[oldIndex].rows.count, 1)
        }
    }
    
    func testRemoveIdentifiableSections() {
        // Given
        let sections = makeSections(count: 10, rowsCount: 100)
        let testIndexes = [0, 1, 8, 9]
        let previousSections = testIndexes.map({ sections[$0] })
        tableViewHelper.show(sections: sections)
        
        // When
        tableViewHelper.remove(sections: previousSections, with: .automatic)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 10 - testIndexes.count)
        XCTAssertEqual(tableViewHelper.sections[0].id, sections[2].id)
        XCTAssertEqual(tableViewHelper.sections[1].id, sections[3].id)
        XCTAssertEqual(tableViewHelper.sections[4].id, sections[6].id)
        XCTAssertEqual(tableViewHelper.sections[5].id, sections[7].id)
    }
    
    func testAppendRowsToIdentifableSectionId() {
        // Given
        let section = makeSection(rowsCount: 5)
        tableViewHelper.show(section: section)
        let newRows = makeRows(count: 5)
        
        // When
        tableViewHelper.append(rows: newRows, to: section.id)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 10)
        XCTAssertEqual(tableViewHelper.sections[0].rows[4].id, section.rows[4].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, newRows[0].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[6].id, newRows[1].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[7].id, newRows[2].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[8].id, newRows[3].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[9].id, newRows[4].id)
    }
    
    func testAppendRowsToIdentifableSection() {
        // Given
        let section = makeSection(rowsCount: 5)
        tableViewHelper.show(section: section)
        let newRows = makeRows(count: 5)
        
        // When
        tableViewHelper.append(rows: newRows, to: section)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 10)
        XCTAssertEqual(tableViewHelper.sections[0].rows[4].id, section.rows[4].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, newRows[0].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[6].id, newRows[1].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[7].id, newRows[2].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[8].id, newRows[3].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[9].id, newRows[4].id)
    }
    
    // MARK: Identifiable Rows
    
    func testReplaceIdentifiableRows() {
        // Given
        let section = makeSection(rowsCount: 100)
        let testIndexes = [0, 1, 98, 99]
        let previousRows = testIndexes.map({ section.rows[$0] })
        let newRows = previousRows.map({ Row(id: $0.id) })
        tableViewHelper.show(section: section)
        
        // When
        tableViewHelper.replace(rows: newRows, with: .automatic)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, 1)
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 100)
        
        for (newIndex, oldIndex) in testIndexes.enumerated() {
            XCTAssertEqual(tableViewHelper.sections[0].rows[oldIndex].id, previousRows[newIndex].id)
            XCTAssertEqual(tableViewHelper.sections[0].rows[oldIndex].uuid, newRows[newIndex].uuid)
        }
    }
    
    func testRemoveIdentifiableRows() {
        // Given
        let section = makeSection(rowsCount: 10)
        let testIndexes = [0, 1, 8, 9]
        let previousRows = testIndexes.map({ section.rows[$0] })
        tableViewHelper.show(section: section)
        
        // When
        tableViewHelper.remove(rows: previousRows, with: .automatic)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections[0].rows.count, 10 - testIndexes.count)
        XCTAssertEqual(tableViewHelper.sections[0].rows[0].id, section.rows[2].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[1].id, section.rows[3].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[4].id, section.rows[6].id)
        XCTAssertEqual(tableViewHelper.sections[0].rows[5].id, section.rows[7].id)
    }
    
    // MARK: - Identifiable sections and rows
    
    func testEnsureIdentifiableSections() {
        // Given
        let initialSections = makeSections(count: 10, rowsCount: 10)
        var newSections = initialSections
        newSections[0] = makeSection(rowsCount: 5)
        newSections[9] = makeSection(rowsCount: 5)
        newSections[1].rows = makeRows(count: 10)
        newSections[8].rows = makeRows(count: 10)
        newSections.insert(makeSection(rowsCount: 10), at: 1)
        newSections.insert(makeSection(rowsCount: 10), at: 8)
        newSections.append(makeSection(rowsCount: 10))
        newSections.append(makeSection(rowsCount: 10))
        tableViewHelper.show(sections: initialSections)
        
        // When
        tableViewHelper.ensure(sections: newSections)
        
        // Then
        XCTAssertEqual(tableViewHelper.sections.count, newSections.count)
        
        for (index, section) in newSections.enumerated() {
            XCTAssertEqual(tableViewHelper.sections[index].id, section.id)
            XCTAssertEqual(tableViewHelper.sections[index].rows.count, section.rows.count)
            
            for (rowIndex, row) in section.rows.enumerated() {
                XCTAssertEqual(tableViewHelper.sections[index].rows[rowIndex].id, row.id)
            }
        }
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

// MARK: - UITableViewDataSource

extension TableViewHelperTests: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableViewHelper.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewHelper.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
