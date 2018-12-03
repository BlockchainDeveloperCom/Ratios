//
//  RatioCreatorViewController.swift
//  Ratios
//
//  Created by Pouria Almassi on 15/9/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit
import PromiseKit

protocol RatioCreatorViewControllerDelegate: class {
    func ratioCreatorViewControllerDidSelectRatio(with numerator: Coin, denominator: Coin)
}

final class RatioCreatorViewController: UIViewController {
    @IBOutlet var numPicker: UIPickerView!
    @IBOutlet var denPicker: UIPickerView!
    @IBOutlet var relationLabel: UILabel!
    private var numCoin: Coin?
    private var denCoin: Coin?
    private var coins = [Coin]()
    weak var delegate: RatioCreatorViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themeable: self)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissViewController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(finish))
        numPicker.dataSource = self
        numPicker.delegate = self
        numPicker.backgroundColor = .clear
        denPicker.dataSource = self
        denPicker.delegate = self
        denPicker.backgroundColor = .clear

        enableFinishButton()
        loadData { [weak self] in
            guard let `self` = self, let firstCoin = self.coins.first else { return }
            self.numPicker.reloadAllComponents()
            self.denPicker.reloadAllComponents()
            self.numCoin = firstCoin
            self.denCoin = firstCoin
            self.enableFinishButton()
        }
    }

    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

    @objc func finish() {
        guard let lCoin = numCoin, let rCoin = denCoin else { return }
        delegate?.ratioCreatorViewControllerDidSelectRatio(with: lCoin, denominator: rCoin)
        dismiss(animated: true, completion: nil)
    }

    // Tad lazy here making a request basically just to present the names. But will leave it as is
    // for now on the off chance that at some point in the future we display more information.
    private func loadData(completion: @escaping () -> ()) {
        when(fulfilled: [API.coin(withId: "neo"), API.coin(withId: "gas"), API.coin(withId: "bitcoin")])
            .done { [weak self] coins in
                guard
                    let `self` = self,
                    let neoCoin = coins.first(where: { $0.id == "neo" }),
                    let gasCoin = coins.first(where: { $0.id == "gas" }),
                    let btcCoin = coins.first(where: { $0.id == "bitcoin" })
                    else { return }
                self.coins = [btcCoin, gasCoin, neoCoin]
                DispatchQueue.main.async {
                    completion()
                }
            }
            .catch { error in
                fatalError("Error: \(error.localizedDescription)")
        }
    }

    private func enableFinishButton() {
        if let _ = numCoin, let _ = denCoin {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

extension RatioCreatorViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coins.count
    }
}

extension RatioCreatorViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let foregroundColor = ThemeService.shared.isDarkThemeEnabled ? UIColor.white : UIColor.black
        return NSAttributedString(string: coins[row].name, attributes: [NSAttributedString.Key.foregroundColor : foregroundColor])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == numPicker {
            numCoin = coins[row]
        } else {
            denCoin = coins[row]
        }
    }
}

extension RatioCreatorViewController: Themeable {
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, relationLabel])
        theme.applyLabelTextColor(labels: [relationLabel])
    }
}
