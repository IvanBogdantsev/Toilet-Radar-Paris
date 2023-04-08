//
//  PresentationUnderlay.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 17.02.2023.
//

import UIKit

final class BannerContainerView: UIView {
    
    enum State {
        case expanded
        case collapsed
    }
    
    var isExpandable: Bool = false {
        didSet {
            guard let superview = superview else { return }
            setupConstraints(superview)
        }
    }
    
    var expansionOffset: CGFloat = 0.0
    private(set) var state: State = .collapsed {
        didSet {
            if oldValue == state { return }
        }
    }
    
    var expansionConstraint: NSLayoutConstraint!
    var initialOffset: CGFloat = 0.0
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        setupConstraints(superview)
    }
    
    typealias CompletionHandler = (_ completed: Bool) -> Void
    
    func setupConstraints(_ superview: UIView) {
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGestureRecognizer)
        
        expansionConstraint = topAnchor.constraint(equalTo: superview.topAnchor)
        expansionConstraint.constant = 400
        
        expansionConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            heightAnchor.constraint(equalToConstant: 600)
        ])
    }
    
    @objc func didPan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        
        let translation = recognizer.translation(in: view)
        
        expansionConstraint.constant += translation.y
        recognizer.setTranslation(.zero, in: view)
        
        if recognizer.state == .ended {
            let velocity = recognizer.velocity(in: view)
            
            if velocity.y >= 0.0 {
                state = .expanded
            } else {
                state = .collapsed
            }
            if velocity.y <= 0.0 {
                state = .expanded
            } else {
                state = .collapsed
            }
            
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: [.allowUserInteraction],
                           animations: {
                self.superview?.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
}
