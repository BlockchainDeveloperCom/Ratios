//
//  Theme.swift
//  Ratios
//
//  Created by Pouria Almassi on 11/9/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit

final class ThemeService {
    static let shared = ThemeService()

    private init() { }

    var theme: Theme? {
        didSet {
            guard let theme = theme else { return }
            applyTheme(theme: theme)
        }
    }

    private var listeners = NSHashTable<UIResponder>.weakObjects()

    func addThemeable(themeable: Themeable) {
        guard
            let themeable = themeable as? UIResponder,
            !listeners.contains(themeable),
            let theme = theme
            else { return }
        listeners.add(themeable)
        applyTheme(theme: theme)
    }

    private func applyTheme(theme: Theme) {
        applyNavigationBarTheme(theme: theme)
        listeners.allObjects
            .compactMap { $0 as? Themeable }
            .forEach { themeableResponder in
                if let delegate = UIApplication.shared.delegate,
                    let windowUnwrapped = delegate.window,
                    let windowDoublyUnwrapped = windowUnwrapped {
                    UIView.transition(
                        with: windowDoublyUnwrapped,
                        duration: 0.2,
                        options: [.curveLinear],
                        animations: {
                            themeableResponder.applyTheme(theme: theme)
                    }, completion: nil)
                }

                if let vc = themeableResponder as? UIViewController {
                    vc.navigationController?.navigationBar.tintColor = theme.backgroundColor
                    vc.navigationController?.navigationBar.barTintColor = theme.backgroundColor
                    vc.navigationController?.navigationBar.barStyle = theme.barStyle
                }
        }
    }

    private func applyNavigationBarTheme(theme: Theme) {
        guard let window = UIApplication.shared.windows.first else { return }
        let navBar = UINavigationBar.appearance()
        navBar.barStyle = theme.barStyle
        navBar.barTintColor = theme.backgroundColor
        navBar.tintColor = theme.tintColor
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.foregroundColor]
        window.tintColor = UIColor.primaryColor
    }
}

protocol Themeable: class {
    func applyTheme(theme: Theme)
}

protocol Theme {
    var backgroundColor: UIColor { get }
    var tintColor: UIColor { get }
    var foregroundColor: UIColor { get }
    var barStyle: UIBarStyle { get }
}

extension Theme {
    func applyBackgroundColor(views: [UIView]) {
        views.forEach {
            $0.backgroundColor = self.backgroundColor
        }
    }

    func applyForegroundColor(views: [UIView]) {
        views.forEach {
            $0.backgroundColor = foregroundColor
        }
    }

    func applyLabelTextColor(labels: [UILabel]) {
        labels.forEach {
            $0.textColor = foregroundColor
        }
    }
}

struct DarkTheme: Theme {
    var backgroundColor: UIColor { return UIColor.darkBackgroundColor }
    var tintColor: UIColor { return UIColor.primaryColor }
    var foregroundColor: UIColor { return UIColor.lightBackgroundColor }
    var barStyle: UIBarStyle { return UIBarStyle.black }
}

struct LightTheme: Theme {
    var backgroundColor: UIColor { return UIColor.lightBackgroundColor }
    var tintColor: UIColor { return UIColor.primaryColor }
    var foregroundColor: UIColor { return UIColor.darkBackgroundColor }
    var barStyle: UIBarStyle { return UIBarStyle.default }
}
