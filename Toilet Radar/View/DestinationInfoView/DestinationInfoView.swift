//
//  DestinationInfoView.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 21.02.2023.
//

import UIKit

final class DestinationInfoView: UIView {
    
    @IBOutlet weak var grabber: UIView!
    
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    
    @IBOutlet weak var routeHighlightsView: UIStackView!
    
    @IBOutlet weak var timeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var distanceActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var prmAccess: UILabel!
    @IBOutlet weak var schedule: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var travelTime: UILabel!
    
    var upperViewHeight: CGFloat {
        upperView.frame.height
    }
    
    var totalHeight: CGFloat {
        (upperView.frame.height + lowerView.frame.height) + max(safeAreaInsets.bottom, 9)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let shadowPath = UIBezierPath(rect: bounds)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
        layer.shadowOffset = .zero
        layer.masksToBounds = false
    }
    
}
