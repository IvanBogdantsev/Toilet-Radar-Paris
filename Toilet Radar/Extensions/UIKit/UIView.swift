//
//  UIView.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 27.01.2023.
//

import UIKit

extension UIView {
    /// prepares view for layout 
    static func forAutoLayout<ViewType: UIView>(frame: CGRect = .zero) -> ViewType {
            let view = ViewType.init(frame: frame)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
}

extension UIView {
    static func fromNibForAutolayout<T: UIView>() -> T {
        let view = Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: self, options: nil)![0] as! T
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func embed(in view: UIView) {
        view.addSubview(self)
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
    func scalexyBy(_ scale: CGFloat) {
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}

extension UIView {
    func fade(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0
        }
    }
    
    func appear(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }
}
