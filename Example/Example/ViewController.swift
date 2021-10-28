//
//  ViewController.swift
//  Example
//
//  Created by Jacob Sikorski on 2021-10-26.
//

import UIKit
import Canoe

class ViewController: UIViewController {
    struct Section: TableViewHelperSection, TableViewHelperIdentifiable {
        enum SectionType: String, CaseIterable {
            case A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
        }

        let id: UUID
        let type: SectionType
        var rows: [SimpleRow]
    }

    private let cellReuseIdentifier = "ReuseIdentifier"

    private lazy var template: [(sectionType: Section.SectionType, rowTypes: [SimpleRow.RowType])] = {
        return Section.SectionType.allCases.map { sectionType in
            return (sectionType, SimpleRow.RowType.allCases)
        }
    }()

    private lazy var actionButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(tappedActionButton))
        return button
    }()

    private lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(tappedEditButton))
        return button
    }()

    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDoneButton))
        return button
    }()

    private lazy var tableViewHelper: TableViewHelper<Section> = {
        return TableViewHelper(frame: .zero, style: .plain)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sample"
        navigationItem.leftBarButtonItem = editButton
        navigationItem.rightBarButtonItem = actionButton

        // Setup view
        view.addSubview(tableViewHelper.tableView)
        tableViewHelper.tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewHelper.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableViewHelper.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableViewHelper.tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableViewHelper.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // Setup table view
        tableViewHelper.tableView.dataSource = self
        tableViewHelper.tableView.delegate = self
        tableViewHelper.tableView.cellLayoutMarginsFollowReadableWidth = true
        tableViewHelper.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableViewHelper.show(sections: makeSections())
    }

    private func makeSections() -> [Section] {
        return template.map { sectionTemplate -> Section in
            Section(id: UUID(), type: sectionTemplate.sectionType, rows: makeRows(with: sectionTemplate.rowTypes))
        }
    }

    private func makeRows(with types: [SimpleRow.RowType]) -> [SimpleRow] {
        return types.map { type in
            return SimpleRow(id: UUID(), type: type)
        }
    }

    @objc private func tappedEditButton() {
        tableViewHelper.tableView.isEditing = true
        navigationItem.leftBarButtonItem = doneButton
    }

    @objc private func tappedDoneButton() {
        tableViewHelper.tableView.isEditing = false
        navigationItem.leftBarButtonItem = editButton
    }

    @objc private func tappedActionButton() {
        let actionSheet = UIAlertController(title: "Action", message: "Select an action", preferredStyle: .actionSheet)
        actionSheet.popoverPresentationController?.barButtonItem = actionButton

        actionSheet.addAction(UIAlertAction(title: "Hard reset", style: .destructive, handler: { _ in
            self.tableViewHelper.show(sections: self.makeSections())
        }))

        actionSheet.addAction(UIAlertAction(title: "Smart reset", style: .destructive, handler: { _ in
            let sections = self.template.map { sectionTemplate -> Section in
                // Attempt to return existing section for the section type
                let oldSectionIndex = self.tableViewHelper.firstSectionIndex(where: { $0.type == sectionTemplate.sectionType })

                if let oldSectionIndex = oldSectionIndex {
                    // Attempt to get existing rows for the row type and section index
                    let rows = sectionTemplate.rowTypes.map { rowType -> SimpleRow in
                        let oldRow = self.tableViewHelper.firstRow(inSectionAt: oldSectionIndex, where: { oldRow in
                            oldRow.type == rowType
                        })

                        return oldRow ?? SimpleRow(id: UUID(), type: rowType)
                    }

                    // Recreate the section with the old id
                    let oldSection = self.tableViewHelper.sections[oldSectionIndex]
                    return Section(id: oldSection.id, type: sectionTemplate.sectionType, rows: rows)
                } else {
                    // Create a new section with new rows
                    return Section(id: UUID(), type: sectionTemplate.sectionType, rows: self.makeRows(with: sectionTemplate.rowTypes))
                }
            }

            self.tableViewHelper.ensure(sections: sections)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewHelper.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewHelper.sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = tableViewHelper.sections[section]
        return "Section `\(section.type.rawValue)`"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let row = tableViewHelper.row(for: indexPath)
        cell.contentConfiguration = row
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = tableViewHelper.row(for: indexPath)
        showActionSheet(for: row, at: indexPath)
    }

    private func showActionSheet(for row: SimpleRow, at indexPath: IndexPath) {
        guard let cell = tableViewHelper.tableView.cellForRow(at: indexPath) else { return }
        let section = tableViewHelper.section(for: indexPath)

        let actionSheet = UIAlertController(title: "Action", message: "Select an action", preferredStyle: .actionSheet)
        actionSheet.popoverPresentationController?.sourceView = cell
        actionSheet.popoverPresentationController?.sourceRect = cell.bounds

        // Remove this row
        actionSheet.addAction(UIAlertAction(title: "Duplicate", style: .default, handler: { [weak self] _ in
            self?.tableViewHelper.insert(row: SimpleRow(id: UUID(), type: row.type), at: IndexPath(row: indexPath.row + 1, section: indexPath.section))
        }))

        // Remove this row
        actionSheet.addAction(UIAlertAction(title: "Remove this row", style: .destructive, handler: { [weak self] _ in
            self?.tableViewHelper.removeRows(at: [indexPath])
        }))

        // Remove all rows of same type
        actionSheet.addAction(UIAlertAction(title: "Remove all \"\(row.type.rawValue)\" rows", style: .destructive, handler: { [weak self] _ in
            self?.tableViewHelper.removeRows(where: { $2.type == row.type })
        }))

        // Remove rows above
        let removeRowsAboveAction = UIAlertAction(title: "Remove rows above", style: .destructive, handler: { [weak self] _ in
            self?.tableViewHelper.removeRows(where: { oldIndexPath, oldSection, oldRow in
                return oldIndexPath.section == indexPath.section && oldIndexPath.row < indexPath.row
            })
        })

        removeRowsAboveAction.isEnabled = indexPath.row > 0
        actionSheet.addAction(removeRowsAboveAction)

        // Remove rows below
        let removeRowsBelowAction = UIAlertAction(title: "Remove rows below", style: .destructive, handler: { [weak self] _ in
            self?.tableViewHelper.removeRows(where: { oldIndexPath, oldSection, oldRow in
                oldIndexPath.section == indexPath.section && oldIndexPath.row > indexPath.row
            })
        })

        removeRowsBelowAction.isEnabled = indexPath.row < section.rows.count - 1
        actionSheet.addAction(removeRowsBelowAction)

        // Cancel button
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableViewHelper.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            tableViewHelper.removeRow(at: indexPath)
            
        case .insert, .none:
            break

        @unknown default:
            break
        }
    }
}

