//
//  SwitchTableViewCell.swift
//  Ratios
//
//  Created by Pouria Almassi on 12/9/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit

protocol SwitchTableViewCellDelegate: class {
    func switchToggledValueDidChange()
}

final class SwitchTableViewCell: UITableViewCell {
    private enum Constant {
        static let horizontalMargin: CGFloat = 16.0
    }

    static let reuseIdentifier = String(describing: SwitchTableViewCell.self)

    weak var delegate: SwitchTableViewCellDelegate?

    private let leftLabel = UILabel()
    private let rightSwitch = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        ThemeService.shared.addThemeable(themeable: self)

        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leftLabel)
        rightSwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rightSwitch)

        leftLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constant.horizontalMargin).isActive = true
        leftLabel.rightAnchor.constraint(equalTo: rightSwitch.leftAnchor, constant: 0).isActive = true
        leftLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        leftLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        leftLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        leftLabel.backgroundColor = .clear
        leftLabel.text = Strings.Settings.nightModeSwitchRow

        rightSwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constant.horizontalMargin).isActive = true
        rightSwitch.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor).isActive = true
        rightSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        rightSwitch.isOn = ThemeService.shared.isDarkThemeEnabled
    }

    func configure(_ leftLabelString: String) {
        leftLabel.text = leftLabelString
    }

    @objc func switchToggled(_ sender: UISwitch) {
        if ThemeService.shared.isDarkThemeEnabled {
            ThemeService.shared.theme = LightTheme()
        } else {
            ThemeService.shared.theme = DarkTheme()
        }
        ThemeService.shared.setDarkThemeEnabled(rightSwitch.isOn)
        delegate?.switchToggledValueDidChange()
    }
}

extension SwitchTableViewCell: Themeable {
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [contentView])
        theme.applyLabelTextColor(labels: [leftLabel])
    }
}
