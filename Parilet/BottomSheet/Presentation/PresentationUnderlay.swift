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
    
    public var expansionOffset: CGFloat = 0.0
    
    public private(set) var state: State = .collapsed {
        didSet {
            
            if oldValue == state { return }
            
        }
    }
    
    var expansionConstraint: NSLayoutConstraint!
    
    var initialOffset: CGFloat = 0.0

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else { return }
        setupConstraints(superview)
    }
    
    public typealias CompletionHandler = (_ completed: Bool) -> Void
    
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
    
    public func show(animated: Bool = true,
                     duration: TimeInterval = 0.2,
                     animations: (() -> Void)? = nil,
                     completion: CompletionHandler? = nil) {
        guard isHidden else {
            completion?(true)
            return
        }
        
        if let superview = superview, expansionConstraint == nil {
            
                expansionConstraint = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            
            expansionConstraint.isActive = true
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        if animated {
            
                expansionConstraint.constant = frame.height
            
            isHidden = false
            superview?.layoutIfNeeded()
            
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: [],
                           animations: { [weak self] in
                guard let self = self else { return }
                
                animations?()
                
                if self.isExpandable {
                    self.expansionConstraint.constant = self.expansionOffset
                } else {
                    self.expansionConstraint.constant = 0.0
                }
                
                self.superview?.layoutIfNeeded()
            }) { completed in
                completion?(completed)
            }
        } else {
            isHidden = false
            completion?(true)
        }
    }
    
    public func hide(animated: Bool = true,
                     duration: TimeInterval = 0.2,
                     animations: (() -> Void)? = nil,
                     completion: CompletionHandler? = nil) {
        guard !isHidden else {
            state = .collapsed
            completion?(true)
            return
        }
        
        if animated {
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: [],
                           animations: { [weak self] in
                guard let self = self else { return }
                
                animations?()
                
                    self.expansionConstraint.constant = self.frame.height
                
                self.superview?.layoutIfNeeded()
            }) { [weak self] completed in
                guard let self = self else { return }
                
                self.isHidden = true
                self.state = .collapsed
                completion?(completed)
            }
        } else {
            isHidden = true
            state = .collapsed
            completion?(true)
        }
    }
}
