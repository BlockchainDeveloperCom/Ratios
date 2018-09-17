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

    // MARK: - Properties

    @IBOutlet var tableView: UITableView!
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData(_:)), for: .valueChanged)
        return refreshControl
    }()
    private var ratios = [Ratio]()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themeable: self)
        configureTableView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRatio))
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

    // MARK: - API

    @objc func loadData(_ sender: UIRefreshControl) {
        loadData()
    }

    private func loadData() {
        when(fulfilled: [API.coin(withId: "neo"), API.coin(withId: "gas")])
            .done { [weak self] coins in
                guard
                    let `self` = self,
                    let neoCoin: Coin = coins.first(where: { $0.id == "neo" }),
                    let gasCoin: Coin = coins.first(where: { $0.id == "gas" })
                    else { return }

                var ratiosSet = Set<Ratio>(self.ratios)
                ratiosSet.insert(Ratio(numerator: gasCoin, denominator: neoCoin))
                self.ratios = Array(ratiosSet).sorted(by: { $0.numeratorCoin.name < $1.numeratorCoin.name })

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
        guard
            let nc = sb.instantiateViewController(withIdentifier: "RatioCreatorNavigationController") as? UINavigationController,
            let ratioCreatorViewController = nc.topViewController as? RatioCreatorViewController else {
                return
        }
        ratioCreatorViewController.delegate = self
        present(nc, animated: true, completion: nil)
    }

    @objc func showSettings() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SettingsNavigationController")
        if !UIDevice.isPhone { vc.modalPresentationStyle = .formSheet }
        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratios.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RatioTableViewCell.reuseIdentifier, for: indexPath) as! RatioTableViewCell
        let ratio = ratios[indexPath.row]
        cell.configure("\(ratio.numeratorCoin.name) to \(ratio.denominatorCoin.name)", ratio.ratioValueString)
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

extension ViewController: RatioCreatorViewControllerDelegate {
    func ratioCreatorViewControllerDidSelectRatio(with numerator: Coin, denominator: Coin) {
        ratios.append(Ratio(numerator: numerator, denominator: denominator))
        tableView.reloadData()
    }
}
