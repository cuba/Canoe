//
//  File.swift
//  
//
//  Created by Jacob Sikorski on 2022-04-05.
//

import Foundation

public protocol SectionsHelperIdentifiable {
    associatedtype ID: Hashable
    var id: ID { get }
}

public protocol SectionsHelperSection {
    associatedtype Row
    var rows: [Row] { get set }
}

public protocol SectionsHelperDelegate: AnyObject {
    func sectionsHelperDidReplaceSections()
    func sectionsHelperDidInsertSections()
    func sectionsHelperDidRemoveSections()
}

public typealias TableViewHelperSection = SectionsHelperSection
public typealias TableViewHelperIdentifiable = SectionsHelperIdentifiable

/// A helper class that manipulates sections and rows
public struct SectionsHelper<Section: SectionsHelperSection> {
    public var sections: [Section] = []
    public weak var delegate: SectionsHelperDelegate?

    // MARK: - Initializers

    public init(sections: [Section] = []) {
        self.sections = sections
    }

    // MARK: - Set sections

    /// Set the sections with the given array
    public mutating func set(sections: [Section]) {
        self.sections = sections
    }

    // MARK: - Get sections

    /// Return the section for the given index path, ignoring the row on the given index path
    public func section(for indexPath: IndexPath) -> Section {
        return sections[indexPath.section]
    }

    /// Return the sections identified by the callback
    public func sections(where callback: (Int, Section) -> Bool) -> [Section] {
        let indexSet = sectionIndexes(where: callback)
        return sections(for: indexSet)
    }

    /// Return the sections for the given indexSet
    public func sections(for indexSet: IndexSet) -> [Section] {
        return sections.enumerated().compactMap { sectionIndex, section in
            guard indexSet.contains(sectionIndex) else { return nil }
            return section
        }
    }

    /// Return the sections for the given index paths
    public func sections(for indexPaths: [IndexPath]) -> [Section] {
        return sections.enumerated().compactMap { sectionIndex, section in
            guard indexPaths.contains(where: { $0.section == sectionIndex}) else { return nil }
            return section
        }
    }

    /// Return the first section identified by the callback
    public func firstSection(where callback: (Int, Section) -> Bool) -> Section? {
        guard let sectionIndex = firstSectionIndex(where: callback) else { return nil }
        return sections[sectionIndex]
    }

    // MARK: - Get section indexes

    /// Return the section indexes identified by the callback
    public func sectionIndexes(where callback: (Int, Section) -> Bool) -> IndexSet {
        var indexSet = IndexSet()

        for (index, section) in sections.enumerated() {
            guard callback(index, section) else { continue }
            indexSet.insert(index)
        }

        return indexSet
    }

    /// Return the first section index identified by the callback
    public func firstSectionIndex(where callback: (Int, Section) -> Bool) -> Int? {
        for (index, section) in sections.enumerated() {
            guard callback(index, section) else { continue }
            return index
        }

        return nil
    }

    // MARK: - Insert sections

    /// Insert a single section to the at the given index
    @discardableResult
    public mutating func insert(section: Section, at index: Int) -> IndexSet {
        return insert(sections: [section], startingAt: index)
    }

    /// Insert a single section to the at the given index
    @discardableResult
    public mutating func insert(sections: [Section], startingAt startIndex: Int) -> IndexSet {
        var indexSet = IndexSet()
        var currentIndex = startIndex

        for section in sections {
            self.sections.insert(section, at: currentIndex)
            indexSet.insert(currentIndex)
            currentIndex += 1
        }

        delegate?.sectionsHelperDidInsertSections()
        return indexSet
    }

    // MARK: - Replace sections

    /// Replace a section at a specific index
    @discardableResult
    public mutating func replace(section: Section, at index: Int) -> IndexSet {
        var indexSet = IndexSet()
        indexSet.insert(index)
        sections[index] = section
        delegate?.sectionsHelperDidReplaceSections()
        return indexSet
    }

    /// Replace all sections given by the callback
    @discardableResult
    public mutating func replaceSections(where callback: (Int, Section) -> Section?) -> IndexSet {
        var indexSet = IndexSet()

        for (index, section) in sections.enumerated() {
            if let newSection = callback(index, section) {
                sections[index] = newSection
                indexSet.insert(index)
            }
        }

        delegate?.sectionsHelperDidReplaceSections()
        return indexSet
    }

    // MARK: - Remove sections

    /// Remove section at the given index
    public mutating func removeSection(at index: Int) {
        let indexSet = IndexSet([index])
        removeSections(in: indexSet)
    }

    /// Remove section at the given indexSet
    public mutating func removeSections(in indexSet: IndexSet) {
        sections = sections.enumerated().compactMap { (offset, section) -> Section? in
            guard !indexSet.contains(offset) else { return nil }
            return section
        }

        delegate?.sectionsHelperDidRemoveSections()
    }

    /// Remove all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns true if the row should be removed
    @discardableResult
    public mutating func removeSections(where callback: (Int, Section) -> Bool) -> IndexSet {
        var indexSet = IndexSet()
        var newSections: [Section] = []

        for (index, section) in sections.enumerated() {
            if callback(index, section) {
                indexSet.insert(index)
            } else {
                newSections.append(section)
            }
        }

        sections = newSections
        delegate?.sectionsHelperDidRemoveSections()
        return indexSet
    }

    // MARK: - Get rows

    /// Return the row for the given index path
    public func row(for indexPath: IndexPath) -> Section.Row {
        return sections[indexPath.section].rows[indexPath.row]
    }

    /// Return the rows for the given index paths
    public func rows(for indexPaths: [IndexPath]) -> [Section.Row] {
        return sections.enumerated().flatMap { sectionIndex, section in
            return sections[sectionIndex].rows.enumerated().compactMap { rowIndex, row in
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                guard indexPaths.contains(indexPath) else { return nil }
                return row
            }
        }
    }

    /// Return the rows identified by the callback
    public func rows(where callback: (IndexPath, Section, Section.Row) -> Bool) -> [Section.Row] {
        return sections.enumerated().flatMap { sectionIndex, section in
            return sections[sectionIndex].rows.enumerated().compactMap { rowIndex, row in
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                guard callback(indexPath, section, row) else { return nil }
                return row
            }
        }
    }

    /// Return the rows at the section index and  identified by the callback
    public func rows(inSectionAt sectionIndex: Int, where callback: (IndexPath, Section.Row) -> Bool) -> [Section.Row] {
        return sections[sectionIndex].rows.enumerated().compactMap { rowIndex, row in
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            guard callback(indexPath, row) else { return nil }
            return row
        }
    }

    /// Return the row identified by the callback
    public func firstRow(where callback: (IndexPath, Section, Section.Row) -> Bool) -> Section.Row? {
        for (index, section) in sections.enumerated() {
            guard let row = firstRow(inSectionAt: index, where: { indexPath, row -> Bool in
                return callback(indexPath, section, row)
            }) else { continue }

            return row
        }

        return nil
    }

    /// Return the row at the section index and  identified by the callback
    public func firstRow(inSectionAt sectionIndex: Int, where callback: (IndexPath, Section.Row) -> Bool) -> Section.Row? {
        for (rowIndex, row) in sections[sectionIndex].rows.enumerated() {
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            guard callback(indexPath, row) else { continue }
            return row
        }

        return nil
    }

    // MARK: - Move rows

    /// Move a row from one index path to another
    public mutating func moveRow(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = sections[sourceIndexPath.section].rows.remove(at: sourceIndexPath.row)
        sections[destinationIndexPath.section].rows.insert(sourceRow, at: destinationIndexPath.row)
    }

    // MARK: - Insert rows

    /// Insert rows starting at the given index path
    /// - Parameters:
    ///   - rows: The rows to insert
    ///   - startIndexPath: The Index path to start inserting the rows into
    @discardableResult
    public mutating func insert(rows: [Section.Row], startingAt startIndexPath: IndexPath) -> [IndexPath] {
        var rowIndex = startIndexPath.row
        var indexPaths: [IndexPath] = []

        for row in rows {
            let indexPath = IndexPath(row: rowIndex, section: startIndexPath.section)
            indexPaths.append(indexPath)
            sections[indexPath.section].rows.insert(row, at: indexPath.row)
            rowIndex += 1
        }

        return indexPaths
    }

    /// Insert a row into the given index path
    /// - Parameters:
    ///   - row: The row to insert
    ///   - indexPath: The Index
    @discardableResult
    public mutating func insert(row: Section.Row, at indexPath: IndexPath) -> [IndexPath] {
        return insert(rows: [row], startingAt: indexPath)
    }

    /// Insert rows before and after the row given within the callback.
    /// - Parameters:
    ///   - callback: The search callback that provides the rows to insert before and after the current row
    @discardableResult
    public mutating func insertRows(where callback: (IndexPath, Section, Section.Row) -> (before: [Section.Row], after: [Section.Row])?) -> [IndexPath] {
        var indexPaths: [IndexPath] = []

        for (sectionIndex, section) in sections.enumerated() {
            var newRows: [Section.Row] = []
            for (rowIndex, oldRow) in section.rows.enumerated() {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                let result = callback(indexPath, section, oldRow)

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

        return indexPaths
    }

    /// Append rows to the end of the section given by the given section index
    /// - Parameters:
    ///   - rows: The rows to insert
    ///   - section: The section index to append the rows into
    @discardableResult
    public mutating func append(rows: [Section.Row], toSectionAt section: Int) -> [IndexPath] {
        let indexPath = IndexPath(row: sections[section].rows.count, section: section)
        return insert(rows: rows, startingAt: indexPath)
    }

    // MARK: - Replace rows

    /// Replace a row at the given index path.
    /// - Parameters:
    ///   - row: The row to update
    ///   - indexPath: The index path of the row
    public mutating func replace(row: Section.Row, at indexPath: IndexPath) {
        sections[indexPath.section].rows[indexPath.row] = row
    }

    /// Replace all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns a new row when it needs to be replaced.
    @discardableResult
    public mutating func replaceRows(where callback: (IndexPath, Section, Section.Row) -> Section.Row?) -> [IndexPath] {
        return sections.enumerated().flatMap { sectionIndex, section in
            return section.rows.enumerated().compactMap { rowIndex, row in
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                guard let newRow = callback(indexPath, section, row) else { return nil }
                sections[sectionIndex].rows[rowIndex] = newRow
                return indexPath
            }
        }
    }

    /// Replace all rows identified by the callback
    /// - Parameters:
    ///   - callback:Returns a new row when it needs to be replaced.
    @discardableResult
    public mutating func replaceRows(inSectionAt sectionIndex: Int, where callback: (IndexPath, Section, Section.Row) -> Section.Row?) -> [IndexPath] {
        return sections[sectionIndex].rows.enumerated().compactMap { rowIndex, row in
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            guard let newRow = callback(indexPath, sections[sectionIndex], row) else { return nil }
            sections[sectionIndex].rows[rowIndex] = newRow
            return indexPath
        }
    }

    // MARK: - Remove rows

    /// Remove a row at the given indexPath
    public mutating func removeRow(at indexPath: IndexPath) {
        removeRows(at: [indexPath])
    }

    /// Remove all rows at the given indexPaths
    public mutating func removeRows(at indexPaths: [IndexPath]) {
        for (sectionIndex, section) in sections.enumerated() {
            var newRows: [Section.Row] = []

            for (rowIndex, row) in section.rows.enumerated() {
                if !indexPaths.contains(where: { $0.row == rowIndex && $0.section == sectionIndex}) {
                    newRows.append(row)
                }

                sections[sectionIndex].rows = newRows
            }
        }
    }

    /// Remove all rows for the given section index and identified by the given callback
    /// - Parameters:
    ///   - section: The section index to remove the rows from
    ///   - callback:Returns true if the row should be removed
    @discardableResult
    public mutating func removeRows(inSectionAt sectionIndex: Int, where callback: (IndexPath, Section.Row) -> Bool) -> [IndexPath] {
        let indexPaths = sections[sectionIndex].rows.enumerated().compactMap { rowIndex, row -> IndexPath? in
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            guard callback(indexPath, row) else { return nil }
            return indexPath
        }

        removeRows(at: indexPaths)
        return indexPaths
    }

    /// Remove all rows identified by the given callback
    /// - Parameters:
    ///   - callback:Returns true if the row should be removed
    @discardableResult
    public mutating func removeRows(where callback: (IndexPath, Section, Section.Row) -> Bool) -> [IndexPath] {
        let indexPaths: [IndexPath] = indexPaths(where: callback)
        removeRows(at: indexPaths)
        return indexPaths
    }

    // MARK: - Index paths

    /// Get the index paths identified by the given callback
    public func indexPaths(where callback: (IndexPath, Section, Section.Row) -> Bool) -> [IndexPath] {
        return sections.enumerated().flatMap { sectionIndex, section -> [IndexPath] in
            return indexPaths(inSectionAt: sectionIndex) { indexPath, row in
                return callback(indexPath, section, row)
            }
        }
    }

    /// Get the index paths for the given section index and identified by the given callback
    public func indexPaths(inSectionAt sectionIndex: Int, where callback: (IndexPath, Section.Row) -> Bool) -> [IndexPath] {
        return sections[sectionIndex].rows.enumerated().compactMap { rowIndex, row in
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            guard callback(indexPath, row) else { return nil }
            return indexPath
        }
    }

    /// Get the index paths for the given indexSet and identified by the given callback
    public func indexPaths(inSectionsAt indexSet: IndexSet, where callback: (IndexPath, Section.Row) -> Bool) -> [IndexPath] {
        return indexSet.flatMap { sectionIndex -> [IndexPath] in
            return indexPaths(inSectionAt: sectionIndex) { indexPath, row in
                return callback(indexPath, row)
            }
        }
    }

    /// Get the index paths for the given callback
    public func firstindexPath(where callback: (IndexPath, Section, Section.Row) -> Bool) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                guard callback(indexPath, section, row) else { continue }
                return indexPath
            }
        }

        return nil
    }

    /// Get the first index paths for the given sectionIndex and identified by the given callback
    public func firstindexPath(inSectionAt sectionIndex: Int, where callback: (IndexPath, Section.Row) -> Bool) -> IndexPath? {
        for (rowIndex, row) in sections[sectionIndex].rows.enumerated() {
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            guard callback(indexPath, row) else { continue }
            return indexPath
        }

        return nil
    }

    /// Get the first index paths for the given indexPath and identified by the given callback
    public func firstindexPath(inSectionsAt indexSet: IndexSet, where callback: (IndexPath, Section.Row) -> Bool) -> IndexPath? {
        for sectionIndex in indexSet {
            for (rowIndex, row) in sections[sectionIndex].rows.enumerated() {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                guard callback(indexPath, row) else { continue }
                return indexPath
            }
        }

        return nil
    }
}
