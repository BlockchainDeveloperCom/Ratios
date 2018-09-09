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
    private enum RErrors: Error {
        case foo
    }

    @IBOutlet var tableView: UITableView!

    private var model = [Double]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()

        let neoPromise = fetchCoin("https://api.coingecko.com/api/v3/coins/neo")
        let gasPromise = fetchCoin("https://api.coingecko.com/api/v3/coins/gas")
        _ = when(fulfilled: [neoPromise, gasPromise]).done { [weak self] coins in
            guard let `self` = self else { return }

            guard let neoCoin: Coin = coins.first(where: { $0.id == "neo" }) else { return }
            guard let gasCoin: Coin = coins.first(where: { $0.id == "gas" }) else { return }
            self.model = [neoCoin.marketData.currentPrice.usdPrice / gasCoin.marketData.currentPrice.usdPrice]

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.register(RatioCell.self, forCellReuseIdentifier: RatioCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    func fetchCoin(_ urlString: String) -> Promise<Coin> {
        return Promise { seal in
            let url = URL(string: urlString)!
            URLSession.shared.dataTask(with: url) { data, _, error in
                do {
                    guard let data = data else {
                        seal.reject(RErrors.foo)
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
        cell.configure("\(model[indexPath.row])")
        return cell
    }
}

final class RatioCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RatioCell.self)

    private let xLabel = UILabel()
    private let yLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        xLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(xLabel)

        //        yLabel.translatesAutoresizingMaskIntoConstraints = false
        //        contentView.addSubview(yLabel)

        let padding: CGFloat = 8
        xLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: padding).isActive = true
        xLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -padding).isActive = true
        xLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding).isActive = true
        xLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding).isActive = true
        xLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true

        //        yLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: padding).isActive = true
        //        yLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -padding).isActive = true
        //        yLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding).isActive = true
        //        yLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding).isActive = true
    }

    func configure(_ labelString: String) {
        xLabel.text = labelString
    }
}
