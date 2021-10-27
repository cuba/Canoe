//
//  SimpleView.swift
//  Example
//
//  Created by Jacob Sikorski on 2021-10-27.
//

import Foundation
import UIKit

class SampleView: UIView, UIContentView {
    private var row: SimpleRow

    var configuration: UIContentConfiguration {
        set { row = newValue as! SimpleRow }
        get { return row }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = .label
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    init(row: SimpleRow) {
        self.row = row
        super.init(frame: .zero)

        // Setup view
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.readableContentGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.readableContentGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.readableContentGuide.bottomAnchor)
        ])

        // Configure with row
        titleLabel.text = row.type.rawValue
        subtitleLabel.text = row.id.uuidString
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
