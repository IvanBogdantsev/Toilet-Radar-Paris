//
//  BottomSheetViewController.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 26.01.2023.
//

import UIKit

final class BottomBannerViewController: UIViewController { //подписать на Banner
    
    private let containerView: BannerContainerView = .forAutoLayout()
    private let destinationInfoView: DestinationInfoView = .fromNib()
    
    override func loadView() {
        view = containerView
    }
                
    override func viewDidLoad() {
        super.viewDidLoad()
        destinationInfoView.embed(in: containerView)
        destinationInfoView.pinToEdges(of: containerView)
    }

}
