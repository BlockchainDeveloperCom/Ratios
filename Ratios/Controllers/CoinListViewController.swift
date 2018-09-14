//
//  CoinListViewController.swift
//  Ratios
//
//  Created by Pouria Almassi on 15/9/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit
import PromiseKit

final class CoinListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private var coins = [Coin]()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissViewController))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        API.coins()
            .done { [weak self] coins in
                guard let `self` = self else { return }
                self.coins = coins.sorted(by: { $0.name < $1.name })
                self.tableView.reloadData()
            }
            .catch { error in
                fatalError("Error: \(error.localizedDescription)")
        }
    }

    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}

extension CoinListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = coins[indexPath.row].name
        return cell
    }
}
