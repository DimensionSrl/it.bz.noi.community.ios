//
//  UIViewController+ShowError.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/2021.
//

import UIKit

extension UIViewController {
    func showError(_ error: Error) {
        let alert = UIAlertController(error: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(
            title: .localized("alert_ok"),
            style: .cancel,
            handler: nil
        )
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
