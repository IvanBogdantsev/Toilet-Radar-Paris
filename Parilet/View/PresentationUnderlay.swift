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
    
    var isExpandable: Bool! {
        didSet {
            setupRecognizer(isExpandable: isExpandable)
        }
    }
    
    private(set) var state: State = .collapsed {
        didSet {
            expansionConstraint.constant = state == .collapsed ? -collapsedOffset : -expandedOffset
        }
    }
    
    private var expansionConstraint: NSLayoutConstraint!
    /// nodoc
    var expandedOffset: CGFloat = 0 {
        didSet {
            guard state == .expanded else { return }
            expansionConstraint.constant = -expandedOffset
            animate()
        }
    }
    /// nodoc
    var collapsedOffset: CGFloat = 0 {
        didSet {
            guard state == .collapsed else { return }
            expansionConstraint.constant = -collapsedOffset
            animate()
        }
    }
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        setupConstraints(superview)
    }
    
    private func setupConstraints(_ superview: UIView) {
        expansionConstraint = topAnchor.constraint(equalTo: superview.bottomAnchor)
        expansionConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            heightAnchor.constraint(equalToConstant: superview.bounds.height)
        ])
    }
    
    private func setupRecognizer(isExpandable: Bool) {
        let panGestureRecognizer = isExpandable ?
        UIPanGestureRecognizer(target: self, action: #selector(didPan)) : UIGestureRecognizer() // idle recognizer
        gestureRecognizers = [panGestureRecognizer]
    }
        
    private func animate() {
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: [.allowUserInteraction],
                       animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        let translation = recognizer.translation(in: view)
        
        if recognizer.state == .changed {
            // rubber band effect
            if expansionConstraint.constant < -expandedOffset {
                let absYPos = abs(expansionConstraint.constant + translation.y)
                let adjustedYPos = expandedOffset * (1 + log10(absYPos / expandedOffset))
                expansionConstraint.constant = -adjustedYPos
                return
            }
            expansionConstraint.constant += translation.y
            recognizer.setTranslation(.zero, in: view)
        }
        
        if recognizer.state == .ended {
            let velocity = recognizer.velocity(in: view)
            if velocity.y >= 0.0 {
                state = .collapsed
            } else {
                state = .expanded
            }
            animate()
        }
    }
    
}
