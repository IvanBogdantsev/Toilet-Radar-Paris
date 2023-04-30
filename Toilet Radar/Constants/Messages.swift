//
//  Messages.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 14.04.2023.
//

typealias OnboardingMessageAndComment = (message: String, comment: String)

enum Messages {
    static let howToStartYourRoute: OnboardingMessageAndComment = (message: Strings.no_selection, comment: Strings.choose_a_point_on_the_map_to_see_details_and_plan_your_route)
}
