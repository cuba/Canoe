import Foundation
import UIKit

/// A helper class that syncronizes with the table view sections and rows
public class TableViewHelper<Section: SectionsHelperSection> {
    public let tableView: UITableView
    public var sectionsHelper: SectionsHelper<Section>

    public var sections: [Section] {
        return sectionsHelper.sections
    }
    
    // MARK: - Initializers

    public init(frame: CGRect, style: UITableView.Style, sections: [Section] = []) {
        self.tableView = UITableView(frame: frame, style: style)
        self.sectionsHelper = SectionsHelper(sections: sections)
    }
    
    public init(tableView: UITableView, sections: [Section] = []) {
        self.tableView = tableView
        self.sectionsHelper = SectionsHelper(sections: sections)
    }
    
    // MARK: - Show
    
    /// Reload the table view with the given sections
    public func show(sections: [Section]) {
        sectionsHelper.set(sections: sections)
        tableView.reloadData()
    }
    
    /// Reload the table view with the given section
    public func show(section: Section) {
        sectionsHelper.set(sections: [section])
        tableView.reloadData()
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
        return sectionsHelper.section(for: indexPath)
    }

    /// Return the first section identified by the callback
    public func firstSection(where callback: (Int, Section) -> Bool) -> Section? {
        return sectionsHelper.firstSection(where: callback)
    }

    /// Return the first section index identified by the callback
    public func firstSectionIndex(where callback: (Int, Section) -> Bool) -> Int? {
        return sectionsHelper.firstSectionIndex(where: callback)
    }
    
    /// Insert a single section to the table view at the given index
    public func insert(section: Section, at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        insert(sections: [section], startingAt: index)
    }
    
    /// Insert a single section to the table view at the given index
    public func insert(sections: [Section], startingAt startIndex: Int, with animation: UITableView.RowAnimation = .automatic) {
        let indexSet = sectionsHelper.insert(sections: sections, startingAt: startIndex)
        tableView.insertSections(indexSet, with: animation)
    }
    
    /// Replace a section at a specific index
    public func replace(section: Section, at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        let indexSet = sectionsHelper.replace(section: section, at: index)
        tableView.reloadSections(indexSet, with: animation)
    }
    
    /// Replace all sections given by the callback
    public func replaceSections(with animation: UITableView.RowAnimation = .automatic, where callback: (Int, Section) -> Section?) {
        let indexSet = sectionsHelper.replaceSections(where: callback)
        tableView.reloadSections(indexSet, with: animation)
    }
    
    /// Remove section at the given index
    public func removeSection(at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        let indexSet = IndexSet([index])
        removeSections(in: indexSet, with: animation)
    }

    /// Remove section at the given indexSet
    public func removeSections(in indexSet: IndexSet, with animation: UITableView.RowAnimation = .automatic) {
        sectionsHelper.removeSections(in: indexSet)
        tableView.deleteSections(indexSet, with: animation)
    }
    
    /// Remove all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns true if the row should be removed
    public func removeSections(with animation: UITableView.RowAnimation = .automatic, where callback: (Int, Section) -> Bool) {
        let indexSet = sectionsHelper.removeSections(where: callback)
        tableView.deleteSections(indexSet, with: animation)
    }
    
    // MARK: - Rows
    
    /// Return the row for the given index path
    public func row(for indexPath: IndexPath) -> Section.Row {
        return sectionsHelper.row(for: indexPath)
    }

    /// Move a row from one index path to another
    public func moveRow(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        sectionsHelper.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }

    /// Return the row identified by the callback
    public func firstRow(where callback: (IndexPath, Section, Section.Row) -> Bool) -> Section.Row? {
        return sectionsHelper.firstRow(where: callback)
    }

    /// Return the row identified by the callback
    public func firstRow(inSectionAt section: Int, where callback: (IndexPath, Section.Row) -> Bool) -> Section.Row? {
        return sectionsHelper.firstRow(inSectionAt: section, where: callback)
    }
    
    /// Insert rows starting at the given index path
    /// - Parameters:
    ///   - rows: The rows to insert
    ///   - startIndexPath: The Index path to start inserting the rows into
    public func insert(rows: [Section.Row], startingAt startIndexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic) {
        let indexPaths = sectionsHelper.insert(rows: rows, startingAt: startIndexPath)
        tableView.insertRows(at: indexPaths, with: animation)
    }
    
    /// Append rows to the end of the section given by the index
    /// - Parameters:
    ///   - rows: The rows to insert
    ///   - section: The section index to append the rows into
    public func append(rows: [Section.Row], toSectionAt section: Int, with animation: UITableView.RowAnimation = .automatic) {
        let indexPaths = sectionsHelper.append(rows: rows, toSectionAt: section)
        tableView.insertRows(at: indexPaths, with: animation)
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
        let indexPaths = sectionsHelper.insertRows(where: callback)
        tableView.insertRows(at: indexPaths, with: animation)
    }
    
    /// Update a row at the given index path.
    /// - Parameters:
    ///   - row: The row to update
    ///   - indexPath: The index path of the row
    ///   - reloadCell: Specify if the cell should be reloaded with this new data
    public func replace(row: Section.Row, at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic, reloadCell: Bool) {
        sectionsHelper.replace(row: row, at: indexPath)
        guard reloadCell else { return }
        tableView.reloadRows(at: [indexPath], with: animation)
    }
    
    /// Update all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns a new row when it needs to be replaced.
    public func replaceRows(with animation: UITableView.RowAnimation = .automatic, where callback: (IndexPath, Section, Section.Row) -> Section.Row?) {
        let indexPaths = sectionsHelper.replaceRows(where: callback)
        tableView.reloadRows(at: indexPaths, with: animation)
    }
    
    /// Remove a row at the given indexPath
    public func removeRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic) {
        removeRows(at: [indexPath])
    }
    
    /// Remove a rows at the given indexPaths
    public func removeRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation = .automatic) {
        sectionsHelper.removeRows(at: indexPaths)
        tableView.deleteRows(at: indexPaths, with: animation)
    }
    
    /// Remove all rows for the given section and identified by the callback
    /// - Parameters:
    ///   - animation: The animation to use to perform the table view updated. Default is `.automatic`
    ///   - section: The section index to remove the rows from
    ///   - callback:Returns true if the row should be removed
    public func removeRows(with animation: UITableView.RowAnimation = .automatic, inSection section: Int, where callback: (IndexPath, Section.Row) -> Bool) {
        let indexPaths = sectionsHelper.removeRows(inSectionAt: section, where: callback)
        removeRows(at: indexPaths, with: animation)
    }
    
    /// Remove all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns true if the row should be removed
    public func removeRows(with animation: UITableView.RowAnimation = .automatic, where callback: (IndexPath, Section, Section.Row) -> Bool) {
        let indexPaths: [IndexPath] = indexPaths(where: callback)
        removeRows(at: indexPaths, with: animation)
    }
    
    // MARK: - Index paths
    
    /// Get the index path for the given callback. Nil is return if the cell doesn't exist in the table view.
    public func indexPaths(where callback: (IndexPath, Section, Section.Row) -> Bool) -> [IndexPath] {
        return sectionsHelper.indexPaths(where: callback)
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

extension TableViewHelper where Section: SectionsHelperIdentifiable {
    /// Return the index of a section given by its id if one exists
    public func index(for sectionId: Section.ID) -> Int? {
        return sectionsHelper.firstSectionIndex(where: { $1.id == sectionId })
    }
    
    /// Return the index of a section if one exists
    public func index(for section: Section) -> Int? {
        return index(for: section.id)
    }
    
    /// Replace all the sections represented by their ids with the given sections. Sections that are not found are ignored
    public func replace(sections: [Section], with animation: UITableView.RowAnimation = .automatic) {
        replaceSections(with: animation) { index, oldSection in
            return sections.first(where: { $0.id == oldSection.id })
        }
    }
    
    /// Remove all sections represented by their ids
    func remove(sections: [Section], with animation: UITableView.RowAnimation = .automatic) {
        remove(sectionIds: Set(sections.map({ $0.id })), with: animation)
    }
    
    /// Remove all sections by the given section ids
    func remove(sectionIds: Set<Section.ID>, with animation: UITableView.RowAnimation = .automatic) {
        removeSections(with: animation) { index, oldSection in
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

extension TableViewHelper where Section.Row: SectionsHelperIdentifiable {
    /// Return the index of a row given by its id if one exists
    public func index(for rowId: Section.Row.ID, inSectionAt sectionIndex: Int) -> Int? {
        return sectionsHelper.indexPaths(inSectionAt: sectionIndex, where: { _, row in
            return row.id == rowId
        }).first?.row
    }
    
    /// Return the index of a row if one exists
    public func index(for row: Section.Row, inSectionAt section: Int) -> Int? {
        return index(for: row.id, inSectionAt: section)
    }
    
    public func replace(rows: [Section.Row], with animation: UITableView.RowAnimation = .automatic) {
        replaceRows(with: animation) { _, _, oldRow in
            return rows.first(where: { $0.id == oldRow.id })
        }
    }
    
    public func remove(rows: [Section.Row], with animation: UITableView.RowAnimation = .automatic) {
        removeRows(with: animation) { _, _, oldRow in
            return rows.contains(where: { $0.id == oldRow.id })
        }
    }
    
    /// Ensure the rows match the given rows for given section index
    public func ensure(rows: [Section.Row], inSectionAt sectionIndex: Int) {
        // 1. Remove rows that are not in the list
        removeRows(inSection: sectionIndex) { _, oldRow in
            !rows.contains(where: { $0.id == oldRow.id })
        }
        
        var rows = rows
        var index = 0
        
        // 2. Add missing rows (A) and move misplaced rows (B)
        // Since we removed all non-wanted rows
        // our rows in the table view have to be less than or equal to the given sections
        // So we can just iterate through the given rows as a source of truth
        while !rows.isEmpty {
            let row = rows.removeFirst()
            
            // 2A. Remove the row if it's in the wrong place
            // We will add them back later
            if let existingIndex = self.index(for: row, inSectionAt: sectionIndex), existingIndex != index {
                // TODO: @JS move the row instead of removing it?
                let indexPath = IndexPath(row: existingIndex, section: sectionIndex)
                removeRow(at: indexPath, with: .automatic)
            }
            
            // 2B. Add missing rows
            // Add this row and advance and add all next missing rows
            // The advance is an optimization not a requirement
            guard let _ = self.index(for: row, inSectionAt: sectionIndex) else {
                var rowsToInsert = [row]
                
                // Advance sections to add all the remaining missing ones
                while let nextNewRow = rows.first, self.index(for: nextNewRow, inSectionAt: sectionIndex) == nil {
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

extension TableViewHelper where Section: SectionsHelperIdentifiable, Section.Row: SectionsHelperIdentifiable {
    /// Return the index of a row if one exists
    public func index(for row: Section.Row, inSectionId sectionId: Section.ID) -> Int? {
        guard let sectionIndex = index(for: sectionId) else { return nil }
        return index(for: row.id, inSectionAt: sectionIndex)
    }
    
    /// Ensure the sections match the given sections
    public func ensure(sections: [Section]) {
        // 1. Remove sections that are not in the list
        removeSections(with: .automatic) { index, oldSection in
            !sections.contains(where: { $0.id == oldSection.id })
        }
        
        // 2. Remove rows that are not in the list
        removeRows(with: .automatic) { _, oldSection, oldRow in
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
    public func ensure(rows: [Section.Row], at sectionId: Section.ID) {
        guard let sectionIndex = firstSectionIndex(where: { $1.id == sectionId}) else {
            // This section id doesn't exist
            return
        }
        
        ensure(rows: rows, inSectionAt: sectionIndex)
    }
}
