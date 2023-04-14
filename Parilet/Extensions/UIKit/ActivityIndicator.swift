//
//  ActivityIndicator.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 14.04.2023.
//

import UIKit

extension UIActivityIndicatorView {
    func shouldAnimate(_ shouldAnimate: Bool) {
        shouldAnimate ? startAnimating() : stopAnimating()
    }
}
