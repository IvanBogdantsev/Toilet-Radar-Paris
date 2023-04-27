//
//  DestinationViewModel.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 01.02.2023.
//

import RxSwift
import RxCocoa
import Foundation
import UIKit

protocol DestinationViewModelInputs {
    func setOnboardingMessage(message: OnboardingMessageAndComment)
    func refreshDestination(with destination: Destination)
    func refreshRoute(with route: Route)
}

protocol DestinationViewModelOutputs {
    typealias Empty = ()
    
    var onboardingMessage: Observable<String>! { get }
    var onboardingComment: Observable<String>! { get }
    var prmAccess: Observable<NSAttributedString>! { get }
    var schedule: Observable<NSAttributedString>! { get }
    var district: Observable<String>! { get }
    var type: Observable<String>! { get }
    var address: Observable<String>! { get }
    var distance: Observable<String>! { get }
    var travelTime: Observable<String>! { get }
    var contentRefreshed: Observable<Empty>! { get }
}

protocol DestinationViewModelType {
    var inputs: DestinationViewModelInputs { get }
    var outputs: DestinationViewModelOutputs { get }
}

final class DestinationViewModel: DestinationViewModelType, DestinationViewModelInputs, DestinationViewModelOutputs {
    
    private let timeFormatter = TimeFormatter()
    private let distanceFormatter = DistanceFormatter()
    private let scheduleFormatter = ScheduleFormatter()
    
    init() {
        self.onboardingMessage = onboarding.map { $0.message }
        
        self.onboardingComment = onboarding.map { $0.comment }
        
        self.prmAccess = rawDestination.compactMap { $0.prmAccess?.frTickCross() }
        
        self.schedule = rawDestination.distinctUntilChanged { $0.schedule == $1.schedule }
            .compactMap { $0.schedule }
            .map { self.scheduleFormatter.schedule(from: $0) }
        
        self.district = rawDestination.compactMap { $0.district }
        
        self.type = rawDestination.compactMap { $0.type?.lowercased().capitalized }
        
        self.address = rawDestination.compactMap { $0.address?.lowercased().capitalized }
        
        self.distance = rawRoute.compactMap { self.distanceFormatter.string(from: $0.distance) }
        
        self.travelTime = rawRoute.compactMap { self.timeFormatter.string(from: $0.travelTime) }
        
        self.contentRefreshed = didRefreshContent.asObservable()
    }
    
    private let didRefreshContent = PublishRelay<Empty>()
    private let onboarding = ReplayRelay<OnboardingMessageAndComment>.create(bufferSize: 1)
    func setOnboardingMessage(message: OnboardingMessageAndComment) {
        onboarding.accept(message)
    }
    
    private let rawDestination = PublishRelay<Destination>()// share?
    func refreshDestination(with destination: Destination) {
        rawDestination.accept(destination)
        didRefreshContent.accept(Empty())
    }
    
    private let rawRoute = PublishRelay<Route>()
    func refreshRoute(with route: Route) {
        rawRoute.accept(route)
    }
    
    var onboardingMessage: Observable<String>!
    var onboardingComment: Observable<String>!
    var prmAccess: Observable<NSAttributedString>!
    var schedule: Observable<NSAttributedString>!
    var district: Observable<String>!
    var type: Observable<String>!
    var address: Observable<String>!
    var distance: Observable<String>!
    var travelTime: Observable<String>!
    var contentRefreshed: Observable<Empty>!
    
    var inputs: DestinationViewModelInputs { self }
    var outputs: DestinationViewModelOutputs { self }
    
}
