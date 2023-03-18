//
//  BottomSheetViewController.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 26.01.2023.
//

import RxSwift
import UIKit

final class BottomBannerViewController: UIViewController { //подписать на Banner
    
    private let viewModel: DestinationViewModelType = DestinationViewModel()
    private let containerView: BannerContainerView = .forAutoLayout()
    private let destinationInfoView: DestinationInfoView = .fromNibForAutolayout()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = containerView
    }
                
    override func viewDidLoad() {
        super.viewDidLoad()
        destinationInfoView.embed(in: containerView)
        destinationInfoView.pinToEdges(of: containerView)
        bindViewModelOutputs()
    }
    
    private func bindViewModelOutputs() {
        viewModel.outputs.prmAccess.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.prmAccess.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.outputs.schedule.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.schedule.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.outputs.district.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.district.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.type.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.type.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.address.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.address.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.distance.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.distance.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.travelTime.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.travelTime.rx.text)
            .disposed(by: disposeBag)
    }
    
    func refreshDestination(with destination: Destination) {
        viewModel.inputs.refreshDestination(with: destination)
    }

    func refreshRoute(with route: Route) {
        viewModel.inputs.refreshRoute(with: route)
    }
    
}
