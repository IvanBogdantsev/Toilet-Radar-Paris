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

extension UIView {
    /// prepares view for layout 
    class func forAutoLayout<ViewType: UIView>(frame: CGRect = .zero, hidden: Bool = false) -> ViewType {
            let view = ViewType.init(frame: frame)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
}

extension UIView {
    func embed(in view: UIView) {
        view.addSubview(self)
        didMoveToSuperview()
    }
}

extension UIView {
    func pinToEdges(of view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension UIView {
    class func fromNibForAutolayout<T: UIView>() -> T {
        let view = Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: self, options: nil)![0] as! T
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
