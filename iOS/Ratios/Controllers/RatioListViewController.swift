//
//  ViewController.swift
//  Ratios
//
//  Created by Pouria Almassi on 9/4/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit
import PromiseKit
import Disk

final class RatioListViewController: UIViewController {

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
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRatio)),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(presentRxViewController)),
        ]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(showSettings))
        NotificationCenter.default.addObserver(self, selector: #selector(loadData(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
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
        do {
            ratios = try Disk.retrieve("ratios.json", from: .documents, as: [Ratio].self)
            for ratio in ratios {
                let numeratorCoin = ratio.numeratorCoin
                let denominatorCoin = ratio.denominatorCoin
                when(fulfilled: [API.coin(withId: numeratorCoin.id), API.coin(withId: denominatorCoin.id)])
                    .done { [weak self] coins in
                        guard let `self` = self else { return }
                        guard let nCoin = coins.first(where: { $0.id == numeratorCoin.id }) else { return }
                        guard let dCoin = coins.first(where: { $0.id == denominatorCoin.id }) else { return }
                        self.insert(Ratio(numerator: nCoin, denominator: dCoin))
                    }
                    .catch { error in
                        fatalError("Error: \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        } catch {
            return
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

    @objc func presentRxViewController() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "RxViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RatioListViewController: UITableViewDataSource {
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

extension RatioListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .destructive, title: "Remove") { [weak self] _, ip in
            self?.deleteRatio(at: ip)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [ip], with: .automatic)
            }, completion: nil)
        }
        return [deleteRowAction]
    }
}

extension RatioListViewController: Themeable {
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, tableView])
    }
}

extension RatioListViewController: RatioCreatorViewControllerDelegate {
    func ratioCreatorViewControllerDidSelectRatio(with numerator: Coin, denominator: Coin) {
        insert(Ratio(numerator: numerator, denominator: denominator))
        tableView.reloadData()
    }
}

// MARK: - Data Management

extension RatioListViewController {
    private func deleteRatio(at indexPath: IndexPath) {
        ratios.remove(at: indexPath.row)
        saveRatiosToDisk()
    }

    private func insert(_ ratio: Ratio) {
        var ratiosSet = Set<Ratio>(ratios)
        if let oldRatio = ratiosSet.first(where: { $0 == ratio }) { ratiosSet.remove(oldRatio) }
        ratiosSet.insert(ratio)
        ratios = Array(ratiosSet).sorted(by: { $0.numeratorCoin.name < $1.numeratorCoin.name })
        saveRatiosToDisk()
    }

    private func saveRatiosToDisk() {
        do {
            try Disk.save(ratios, to: .documents, as: "ratios.json")
        } catch {
            print("Could not save to disk.")
        }
    }
}








import RxSwift

final class RxViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Sequences

        //let helloSequence = Observable.from(["H","e","l","l","o"])
        //_ = helloSequence.subscribe { event in
        //    switch event {
        //    case .next(let value):
        //        print(value)
        //    case .error(let error):
        //        print(error)
        //    case .completed:
        //        print("completed")
        //    }
        //}

        // MARK: - Subjects - Publish Subject

        let aPublishSubject = PublishSubject<String>()

        // another way to subscribe
        // s0 is subscribing before any changes to the PublishSubject after 0 and 1 have been 'onNext'ed.
        // So it will get updates from here going forward.
        let s0 = aPublishSubject.subscribe(onNext: { print("first subscriber: \($0)") })

        aPublishSubject.onNext("0")

        // one way subscribe
        // _ = ps.subscribe { event in
        //     switch event {
        //     case .next(let value): print(value)
        //     default: ()
        //     }
        // }

        aPublishSubject.onNext("1")

        // s1 is subscribing to changes for the PublishSubject after 0 and 1 have been 'onNext'ed.
        // So it will _only_ get updates from here going forward.
        let s1 = aPublishSubject.subscribe(onNext: { print("second subscriber: \($0)") })

        aPublishSubject.onNext("2")

        // MARK: - Subjects - Behavior Subject



        
    }
}
