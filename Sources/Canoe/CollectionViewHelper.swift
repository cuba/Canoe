//
//  File.swift
//  
//
//  Created by Jacob Sikorski on 2022-04-06.
//

import UIKit

public class CollectionViewHelper<Section: SectionsHelperSection> {
    public let collectionView: UICollectionView
    public var sectionsHelper: SectionsHelper<Section>

    // MARK: - Initializers

    public init(collectionView: UICollectionView, sections: [Section] = []) {
        self.collectionView = collectionView
        self.sectionsHelper = SectionsHelper(sections: sections)
    }

    // MARK: - Show
    
    /// Reload the table view with the given sections
    public func show(sections: [Section]) {
        sectionsHelper.set(sections: sections)
        collectionView.reloadData()
    }

    /// Reload the table view with the given section
    public func show(section: Section) {
        sectionsHelper.set(sections: [section])
        collectionView.reloadData()
    }

    /// Insert a single section to the table view at the given index
    public func insert(sections: [Section], startingAt startIndex: Int) {
        let indexSet = sectionsHelper.insert(sections: sections, startingAt: startIndex)
        collectionView.insertSections(indexSet)
    }

    /// Replace a section at a specific index
    public func replace(section: Section, at index: Int) {
        let indexSet = sectionsHelper.replace(section: section, at: index)
        collectionView.reloadSections(indexSet)
    }
}
