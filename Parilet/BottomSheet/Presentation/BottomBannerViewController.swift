//
//  BottomSheetViewController.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 26.01.2023.
//

import RxSwift
import UIKit

final class BottomBannerViewController: UIViewController {
    
    private let viewModel: DestinationViewModelType = DestinationViewModel()
    private let containerView: BannerContainerView = .forAutoLayout()
    private let destinationInfoView: DestinationInfoView = .fromNibForAutolayout()
    private let disposeBag = DisposeBag()
    
    var routeHighlightsRefreshing: Bool! {
        didSet {
            destinationInfoView.timeActivityIndicator.shouldAnimate(routeHighlightsRefreshing)
            destinationInfoView.distanceActivityIndicator.shouldAnimate(routeHighlightsRefreshing)
            destinationInfoView.travelTime.isHidden = routeHighlightsRefreshing
            destinationInfoView.distance.isHidden = routeHighlightsRefreshing
        }
    }
    
    var isExpandable: Bool! {
        didSet {
            containerView.isExpandable = isExpandable
            destinationInfoView.grabber.isHidden = !isExpandable
        }
    }
    
    var isOnboarding: Bool! {
        didSet {
            destinationInfoView.routeHighlightsView.isHidden = isOnboarding
        }
    }
    
    override func loadView() {
        view = containerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        destinationInfoView.embed(in: containerView)
        destinationInfoView.pinToEdges(of: containerView)
        bindViewModelOutputs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshContentHeights()
    }
    
    private func bindViewModelOutputs() {
        viewModel.outputs.onboardingMessage.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.mainLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.onboardingComment.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.secondaryLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.prmAccess.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.prmAccess.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.outputs.schedule.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.schedule.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.outputs.district.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.secondaryLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.type.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.type.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.address.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.mainLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.distance.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.distance.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.travelTime.asDriver(onErrorDriveWith: .empty())
            .drive(destinationInfoView.travelTime.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.contentRefreshed
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { self.refreshContentHeights() })
            .disposed(by: disposeBag)
    }
    
    private func refreshContentHeights() {
        destinationInfoView.layoutIfNeeded()
        containerView.collapsedOffset = destinationInfoView.upperViewHeight
        containerView.expandedOffset = destinationInfoView.totalHeight
    }
    
    func setOnboardingMessage(message: OnboardingMessageAndComment) {
        viewModel.inputs.setOnboardingMessage(message: message)
    }
    
    func refreshDestination(with destination: Destination) {
        viewModel.inputs.refreshDestination(with: destination)
    }
    
    func refreshRoute(with route: Route) {
        viewModel.inputs.refreshRoute(with: route)
    }
    
}
