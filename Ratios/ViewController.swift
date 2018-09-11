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
    private var isDark = true // tmp

    private enum RatiosError: Error {
        case generic
    }

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(toggleTheme))
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
        let neoPromise = fetchCoin("https://api.coingecko.com/api/v3/coins/neo")
        let gasPromise = fetchCoin("https://api.coingecko.com/api/v3/coins/gas")
        when(fulfilled: [neoPromise, gasPromise]).done { [weak self] coins in
            guard
                let `self` = self,
                let neoCoin: Coin = coins.first(where: { $0.id == "neo" }),
                let gasCoin: Coin = coins.first(where: { $0.id == "gas" })
                else { return }
            self.model = [Coin.ratio(numeratorCoin: neoCoin, denominatorCoin: gasCoin)]
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }.catch { error in
            fatalError("Error: \(error.localizedDescription)")
        }
    }

    private func fetchCoin(_ urlString: String) -> Promise<Coin> {
        return Promise { seal in
            let url = URL(string: urlString)!
            URLSession.shared.dataTask(with: url) { data, _, error in
                do {
                    guard let data = data else {
                        seal.reject(RatiosError.generic)
                        return
                    }
                    let coin = try JSONDecoder().decode(Coin.self, from: data)
                    seal.fulfill(coin)
                } catch {
                    seal.reject(error)
                }
                }.resume()
        }
    }

    // tmp
    @objc func toggleTheme() {
        if isDark {
            ThemeService.shared.theme = LightTheme()
            isDark = false
        } else {
            ThemeService.shared.theme = DarkTheme()
            isDark = true
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RatioTableViewCell.reuseIdentifier, for: indexPath) as! RatioTableViewCell
        cell.configure("NEO to Gas", model[indexPath.row])
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
