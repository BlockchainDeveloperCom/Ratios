//
//  ViewController.swift
//  Ratios
//
//  Created by Pouria Almassi on 9/4/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit
import PromiseKit

final class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData(_:)), for: .valueChanged)
        return refreshControl
    }()

    private var model = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themeable: self)
        configureTableView()
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRatio))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(showSettings))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func configureTableView() {
        tableView.rowHeight = 64
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RatioTableViewCell.self, forCellReuseIdentifier: RatioTableViewCell.reuseIdentifier)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
    }

    @objc func loadData(_ sender: UIRefreshControl) {
        loadData()
    }

    private func loadData() {
        when(fulfilled: [API.coin(withSymbol: "neo"), API.coin(withSymbol: "gas")])
            .done { [weak self] coins in
                guard
                    let `self` = self,
                    let neoCoin: Coin = coins.first(where: { $0.id == "neo" }),
                    let gasCoin: Coin = coins.first(where: { $0.id == "gas" })
                    else { return }
                self.model = [Coin.ratio(numeratorCoin: gasCoin, denominatorCoin: neoCoin)]
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
            }
            .catch { error in
                fatalError("Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions

    @objc func addRatio() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CoinListNavigationController")
        present(vc, animated: true, completion: nil)
    }

    @objc func showSettings() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SettingsNavigationViewController")
        if !UIDevice.isPhone { vc.modalPresentationStyle = .formSheet }
        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RatioTableViewCell.reuseIdentifier, for: indexPath) as! RatioTableViewCell
        cell.configure("Gas to NEO", model[indexPath.row])
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: Themeable {
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, tableView])
    }
}
