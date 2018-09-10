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
    private enum RatiosError: Error {
        case generic
    }

    @IBOutlet var tableView: UITableView!

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData(_:)), for: .valueChanged)
        return refreshControl
    }()

    private var model = [Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func configureTableView() {
        tableView.rowHeight = 64
        tableView.dataSource = self
        tableView.register(RatioCell.self, forCellReuseIdentifier: RatioCell.reuseIdentifier)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
    }

    @objc func loadData(_ sender: UIRefreshControl) {
        loadData()
    }

    private func loadData() {
        let neoPromise = fetchCoin("https://api.coingecko.com/api/v3/coins/neo")
        let gasPromise = fetchCoin("https://api.coingecko.com/api/v3/coins/gas")
        _ = when(fulfilled: [neoPromise, gasPromise]).done { [weak self] coins in
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
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RatioCell.reuseIdentifier, for: indexPath) as! RatioCell
        let s = String(format: "%.3f", model[indexPath.row])
        cell.configure(s)
        return cell
    }
}

final class RatioCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RatioCell.self)

    private let label = UILabel()
    private let yLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }

    func configure(_ labelString: String) {
        label.text = labelString
    }
}
