import Foundation
import UIKit

public protocol TableViewHelperIdentifiable {
    associatedtype ID: Hashable
    var id: ID { get }
}

public protocol TableViewHelperSection {
    associatedtype Row
    var rows: [Row] { get set }
}

/// A helper class that syncronizes with the table view sections and rows
public class TableViewHelper<Section: TableViewHelperSection> {
    public private(set) var sections: [Section] = []
    public let tableView: UITableView
    
    // MARK: - Initializers
    
    public init(tableView: UITableView, sections: [Section] = []) {
        self.tableView = tableView
        self.sections = sections
    }
    
    // MARK: - Show
    
    /// Reload the table view with the given sections
    public func show(sections: [Section]) {
        self.sections = sections
        tableView.reloadData()
    }
    
    /// Reload the table view with the given section
    public func show(section: Section) {
        show(sections: [section])
    }
    
    // MARK: - Helpers
    
    /// Perform update on the table view between `beginUpdates` and `endUpdates`
    public func performUpdates(_ changes: (UITableView) -> Void) {
        tableView.beginUpdates()
        changes(tableView)
        tableView.endUpdates()
    }
    
    // MARK: - Sections
    
    /// Return the section for the given index path, ignoring the given row
    public func section(for indexPath: IndexPath) -> Section {
        return sections[indexPath.section]
    }
    
    /// Insert a single section to the table view at the given index
    public func insert(section: Section, at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        insert(sections: [section], startingAt: index)
    }
    
    /// Insert a single section to the table view at the given index
    public func insert(sections: [Section], startingAt startIndex: Int, with animation: UITableView.RowAnimation = .automatic) {
        var indexSet = IndexSet()
        var currentIndex = startIndex
        
        for section in sections {
            self.sections.insert(section, at: currentIndex)
            indexSet.insert(currentIndex)
            currentIndex += 1
        }
        
        tableView.insertSections(indexSet, with: animation)
    }
    
    /// Replace a section at a specific index
    public func replace(section: Section, at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        var indexSet = IndexSet()
        indexSet.insert(index)
        sections[index] = section
        tableView.reloadSections(indexSet, with: animation)
    }
    
    /// Replace all sections given by the callback
    public func replaceSections(with animation: UITableView.RowAnimation = .automatic, where callback: (Section) -> Section?) {
        var indexSet = IndexSet()
        
        for (index, section) in sections.enumerated() {
            if let newSection = callback(section) {
                sections[index] = newSection
                indexSet.insert(index)
            }
        }
        
        tableView.reloadSections(indexSet, with: animation)
    }
    
    /// Remove section at the given index
    public func removeSection(at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        var indexSet = IndexSet()
        indexSet.insert(index)
        sections.remove(at: index)
        tableView.deleteSections(indexSet, with: animation)
    }
    
    /// Remove all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns true if the row should be removed
    public func removeSections(with animation: UITableView.RowAnimation = .automatic, where callback: (Section) -> Bool) {
        var indexSet = IndexSet()
        var newSections: [Section] = []
        
        for (index, section) in sections.enumerated() {
            if callback(section) {
                indexSet.insert(index)
            } else {
                newSections.append(section)
            }
        }
        
        sections = newSections
        tableView.deleteSections(indexSet, with: animation)
    }
    
    // MARK: - Rows
    
    /// Return the row for the given index path
    public func row(for indexPath: IndexPath) -> Section.Row {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    /// Insert rows starting at the given index path
    /// - Parameters:
    ///   - rows: The rows to insert
    ///   - startIndexPath: The Index path to start inserting the rows into
    public func insert(rows: [Section.Row], startingAt startIndexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic) {
        var rowIndex = startIndexPath.row
        var indexPaths: [IndexPath] = []
        
        for row in rows {
            let indexPath = IndexPath(row: rowIndex, section: startIndexPath.section)
            indexPaths.append(indexPath)
            sections[indexPath.section].rows.insert(row, at: indexPath.row)
            rowIndex += 1
        }
        
        tableView.insertRows(at: indexPaths, with: animation)
    }
    
    /// Append rows to the end of the section given by the index
    /// - Parameters:
    ///   - rows: The rows to insert
    ///   - section: The section index to append the rows into
    public func append(rows: [Section.Row], toSectionAt section: Int, with animation: UITableView.RowAnimation = .automatic) {
        let indexPath = IndexPath(row: sections[section].rows.count, section: section)
        insert(rows: rows, startingAt: indexPath, with: animation)
    }
    
    /// Insert a row into the given index path
    /// - Parameters:
    ///   - row: The row to insert
    ///   - indexPath: The Index
    public func insert(row: Section.Row, at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic) {
        insert(rows: [row], startingAt: indexPath, with: animation)
    }
    
    /// Insert rows before and after the row given within the callback.
    /// - Parameters:
    ///   - callback: The search callback that provides the rows to insert before and after the current row
    public func insertRows(with animation: UITableView.RowAnimation = .automatic, where callback: (Section, Section.Row) -> (before: [Section.Row], after: [Section.Row])?) {
        var indexPaths: [IndexPath] = []
        
        for (sectionIndex, section) in sections.enumerated() {
            var newRows: [Section.Row] = []
            for oldRow in section.rows {
                let result = callback(section, oldRow)
                
                // Insert before rows
                for row in result?.before ?? [] {
                    let rowIndex = newRows.count
                    newRows.append(row)
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    indexPaths.append(indexPath)
                }
                
                // Put back existing row
                newRows.append(oldRow)
                
                // Insert after rows
                for row in result?.after ?? [] {
                    let rowIndex = newRows.count
                    newRows.append(row)
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    indexPaths.append(indexPath)
                }
            }
            
            sections[sectionIndex].rows = newRows
        }
        
        tableView.insertRows(at: indexPaths, with: animation)
    }
    
    /// Update a row at the given index path.
    /// - Parameters:
    ///   - row: The row to update
    ///   - indexPath: The index path of the row
    ///   - reloadCell: Specify if the cell should be reloaded with this new data
    public func replace(row: Section.Row, at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic, reloadCell: Bool) {
        sections[indexPath.section].rows[indexPath.row] = row
        guard reloadCell else { return }
        tableView.reloadRows(at: [indexPath], with: animation)
    }
    
    /// Update all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns a new row when it needs to be replaced.
    public func replaceRows(with animation: UITableView.RowAnimation = .automatic, where callback: (Section, Section.Row) -> Section.Row?) {
        var indexPaths: [IndexPath] = []
        
        for (sectionIndex, section) in sections.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                if let newRow = callback(section, row) {
                    indexPaths.append(IndexPath(row: rowIndex, section: sectionIndex))
                    sections[sectionIndex].rows[rowIndex] = newRow
                }
            }
        }
        
        tableView.reloadRows(at: indexPaths, with: animation)
    }
    
    /// Remove a row at the given indexPath
    public func removeRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic) {
        removeRows(at: [indexPath])
    }
    
    /// Remove a rows at the given indexPaths
    public func removeRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation = .automatic) {
        for (sectionIndex, section) in sections.enumerated() {
            var newRows: [Section.Row] = []
            
            for (rowIndex, row) in section.rows.enumerated() {
                if !indexPaths.contains(where: { $0.row == rowIndex && $0.section == sectionIndex}) {
                    newRows.append(row)
                }
                
                sections[sectionIndex].rows = newRows
            }
        }
        
        tableView.deleteRows(at: indexPaths, with: animation)
    }
    
    /// Remove all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns true if the row should be removed
    public func removeRows(with animation: UITableView.RowAnimation = .automatic, where callback: (Section, Section.Row) -> Bool) {
        var indexPaths: [IndexPath] = []
        
        for (sectionIndex, section) in sections.enumerated() {
            var newRows: [Section.Row] = []
            
            for (rowIndex, row) in section.rows.enumerated() {
                if callback(section, row) {
                    indexPaths.append(IndexPath(row: rowIndex, section: sectionIndex))
                } else {
                    newRows.append(row)
                }
            }
            
            sections[sectionIndex].rows = newRows
        }
        
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // MARK: - Index paths
    
    /// Get the index path for the given callback. Nil is return if the cell doesn't exist in the table view.
    public func indexPaths(where callback: (Section, Section.Row) -> Bool) -> [IndexPath] {
        var results: [IndexPath] = []
        
        for (sectionIndex, section) in sections.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                if callback(section, row) {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    results.append(indexPath)
                }
            }
        }
        
        return results
    }
    
    /// Return the row and index path of the cell. Nil is return if the cell doesn't exist in the table view.
    public func rowAndIndexPath(for cell: UITableViewCell) -> (indexPath: IndexPath, row: Section.Row)? {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure("Index path not found for cell. Impossible!")
            return nil
        }
        
        let row = self.row(for: indexPath)
        return (indexPath, row)
    }
}

// MARK: - Identifiable Section

extension TableViewHelper where Section: TableViewHelperIdentifiable {
    /// Return the index of a section given by its id if one exists
    public func index(for sectionId: Section.ID) -> Int? {
        return sections.firstIndex(where: { $0.id == sectionId })
    }
    
    /// Return the index of a section if one exists
    public func index(for section: Section) -> Int? {
        return index(for: section.id)
    }
    
    /// Replace all the sections represented by their ids with the given sections. Sections that are not found are ignored
    public func replace(sections: [Section], with animation: UITableView.RowAnimation = .automatic) {
        replaceSections(with: animation) { oldSection in
            return sections.first(where: { $0.id == oldSection.id })
        }
    }
    
    /// Remove all sections represented by their ids
    func remove(sections: [Section], with animation: UITableView.RowAnimation = .automatic) {
        remove(sectionIds: Set(sections.map({ $0.id })), with: animation)
    }
    
    /// Remove all sections by the given section ids
    func remove(sectionIds: Set<Section.ID>, with animation: UITableView.RowAnimation = .automatic) {
        removeSections(with: animation) { oldSection in
            return sectionIds.contains(oldSection.id)
        }
    }
    
    /// Append rows to the the end section given by the sectionId
    func append(rows: [Section.Row], to sectionId: Section.ID, with animation: UITableView.RowAnimation = .automatic) {
        guard let index = index(for: sectionId) else { return }
        append(rows: rows, toSectionAt: index, with: animation)
    }
    
    /// Append rows to the end of the given section. The section id is the only thing used. All other properties are ignored.
    func append(rows: [Section.Row], to section: Section, with animation: UITableView.RowAnimation = .automatic) {
        append(rows: rows, to: section.id, with: animation)
    }
}

// MARK: - Identifiable Row

extension TableViewHelper where Section.Row: TableViewHelperIdentifiable {
    /// Return the index of a row given by its id if one exists
    public func index(for rowId: Section.Row.ID, atSectionIndex section: Int) -> Int? {
        return sections[section].rows.firstIndex(where: { $0.id == rowId })
    }
    
    /// Return the index of a row if one exists
    public func index(for row: Section.Row, atSectionIndex section: Int) -> Int? {
        return index(for: row.id, atSectionIndex: section)
    }
    
    public func replace(rows: [Section.Row], with animation: UITableView.RowAnimation = .automatic) {
        replaceRows(with: animation) { _, oldRow in
            return rows.first(where: { $0.id == oldRow.id })
        }
    }
    
    func remove(rows: [Section.Row], with animation: UITableView.RowAnimation = .automatic) {
        removeRows(with: animation) { _, oldRow in
            return rows.contains(where: { $0.id == oldRow.id })
        }
    }
}

extension TableViewHelper where Section: TableViewHelperIdentifiable, Section.Row: TableViewHelperIdentifiable {
    /// Return the index of a row if one exists
    public func index(for row: Section.Row, at sectionId: Section.ID) -> Int? {
        guard let sectionIndex = index(for: sectionId) else { return nil }
        return index(for: row.id, atSectionIndex: sectionIndex)
    }
    
    /// Ensure the sections match the given sections
    func ensure(sections: [Section]) {
        // 1. Remove sections that are not in the list
        removeSections(with: .automatic) { oldSection in
            !sections.contains(where: { $0.id == oldSection.id })
        }
        
        // 1. Remove rows that are not in the list
        removeRows(with: .automatic) { oldSection, oldRow in
            guard let newSection = sections.first(where: { $0.id == oldSection.id }) else {
                assertionFailure("Impossible because we removed sections that shouldn't be here")
                return true
            }
            
            return !newSection.rows.contains(where: { $0.id == oldRow.id })
        }
        
        var sections = sections
        var index = 0
        
        // 3. Add missing sections (A), move misplaced rows (B) and handle the rows per section (C)
        // Since we removed all non-wanted sections
        // our sections in the table view have to be less than or equal to the given sections
        // So we can just iterate through the given sections as a source of truth
        while !sections.isEmpty {
            let section = sections.removeFirst()
            
            // 3A. Remove the sections if it's in the wrong place
            // Remove the section if it's in the wrong place or has the wrong rows
            // We will add them back later
            if let existingIndex = self.index(for: section), existingIndex != index {
                // TODO: @JS move the section instead of removing it?
                removeSection(at: existingIndex, with: .automatic)
            }
            
            // 3B. Add back missing rows
            guard let _ = self.index(for: section) else {
                var sectionsToInsert = [section]
                
                // Advance sections to add all the remaining missing ones
                while let nextNewSection = sections.first, self.index(for: nextNewSection) == nil {
                    sectionsToInsert.append(sections.removeFirst())
                }
                
                insert(sections: sectionsToInsert, startingAt: index)
                index += sectionsToInsert.count
                continue
            }
            
            // 3C. Now handle the rows
            ensure(rows: section.rows, at: section.id)
            index += 1
        }
    }
    
    /// Ensure the rows match the given rows for the sectionId
    func ensure(rows: [Section.Row], at sectionId: Section.ID) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else {
            // This section id doesn't exist
            return
        }
        
//        let indexPaths = sections[sectionIndex].rows.enumerated().compactMap { index, oldRow -> IndexPath? in
//            guard rows.contains(where: { $0.id == oldRow.id }) else {
//                return IndexPath(row: index, section: sectionIndex)
//            }
//        }
//        
//        removeRow
                
        // 1. Remove rows that are not in the list
        removeRows(with: .automatic) { oldSection, oldRow in
            guard oldSection.id == sectionId else {
                return false
            }
            
            return !rows.contains(where: { $0.id == oldRow.id })
        }
        
        var rows = rows
        var index = 0
        
        // 3. Add missing rows (A) and move misplaced rows (B)
        // Since we removed all non-wanted rows
        // our rows in the table view have to be less than or equal to the given sections
        // So we can just iterate through the given rows as a source of truth
        while !rows.isEmpty {
            let row = rows.removeFirst()
            
            // 3A. Remove the row if it's in the wrong place
            // We will add them back later
            if let existingIndex = self.index(for: row, atSectionIndex: sectionIndex), existingIndex != index {
                // TODO: @JS move the row instead of removing it?
                let indexPath = IndexPath(row: existingIndex, section: sectionIndex)
                removeRow(at: indexPath, with: .automatic)
            }
            
            // 3B. Add missing rows
            // Add this row and advance and add all next missing rows
            // The advance is an optimization not a requirement
            guard let _ = self.index(for: row, atSectionIndex: sectionIndex) else {
                var rowsToInsert = [row]
                
                // Advance sections to add all the remaining missing ones
                while let nextNewRow = rows.first, self.index(for: nextNewRow, atSectionIndex: sectionIndex) == nil {
                    rowsToInsert.append(rows.removeFirst())
                }
                
                let indexPath = IndexPath(row: index, section: sectionIndex)
                insert(rows: rowsToInsert, startingAt: indexPath)
                index += rowsToInsert.count
                continue
            }
            
            index += 1
        }
    }
}
