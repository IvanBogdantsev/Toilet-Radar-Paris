//
//  UIView.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 27.01.2023.
//

import UIKit

extension UIView {
    /// animates changes to the view with reasonable duration and delay.
    class func animateDetent(animations: @escaping () -> Void) {
        self.animate(withDuration: 0.3, delay: .nan, options: [.curveEaseOut], animations: animations)
    }
}
