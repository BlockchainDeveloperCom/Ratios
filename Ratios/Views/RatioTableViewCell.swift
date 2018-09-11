//
//  RatioTableViewCell.swift
//  Ratios
//
//  Created by Pouria Almassi on 11/9/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit

final class RatioTableViewCell: UITableViewCell {
    private enum Constant {
        static let horizontalMargin: CGFloat = 16.0
    }

    static let reuseIdentifier = String(describing: RatioTableViewCell.self)

    private let leftLabel = UILabel()
    private let rightLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        ThemeService.shared.addThemeable(themeable: self)

        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leftLabel)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rightLabel)

        leftLabel.widthAnchor.constraint(equalTo: rightLabel.widthAnchor).isActive = true
        leftLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constant.horizontalMargin).isActive = true
        leftLabel.rightAnchor.constraint(equalTo: rightLabel.leftAnchor, constant: 0).isActive = true
        leftLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        leftLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        leftLabel.backgroundColor = .clear

        rightLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constant.horizontalMargin).isActive = true
        rightLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        rightLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        rightLabel.textAlignment = .right
        rightLabel.backgroundColor = .clear
    }

    func configure(_ leftLabelString: String, _ rightLabelString: String) {
        leftLabel.text = leftLabelString
        rightLabel.text = rightLabelString
    }

}

extension RatioTableViewCell: Themeable {
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [contentView])
        theme.applyLabelTextColor(labels: [leftLabel, rightLabel])
    }
}
