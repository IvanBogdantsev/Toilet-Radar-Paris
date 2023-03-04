//
//  UIViewController.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 21.02.2023.
//

import UIKit

extension UIViewController {
    /// adds child UIViewController and adds its view to parent's view hierarchy
    func embed(_ viewController: UIViewController, in view: UIView) {
        view.addSubview(viewController.view)
        addChild(viewController)
        viewController.didMove(toParent: self)
    }
}
