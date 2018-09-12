//
//  SettingsViewController.swift
//  Ratios
//
//  Created by Pouria Almassi on 12/9/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themeable: self)
        configureTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSettingsViewController))
    }

    @objc func dismissSettingsViewController() {
        dismiss(animated: true, completion: nil)
    }

    private func configureTableView() {
        tableView.rowHeight = 64
        tableView.dataSource = self
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseIdentifier, for: indexPath) as! SwitchTableViewCell
        cell.configure(Strings.Settings.nightModeSwitchRow)
        return cell
    }
}

extension SettingsViewController: Themeable {
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, tableView])
    }
}

extension SettingsViewController: SwitchTableViewCellDelegate {
    func switchToggledValueDidChange() {
        tableView.reloadData()
    }
}
