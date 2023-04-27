//
//  UIAlertController.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 22.04.2023.
//

import class UIKit.UIAlertController
import class UIKit.UIAlertAction
import class UIKit.UIApplication
import class Foundation.Bundle
import struct Foundation.URL

extension UIAlertController {
    static func promptToEnableLocation() -> UIAlertController {
        let alertController = UIAlertController(
            title: Strings.turn_on_location_services_to_allow_to_determine_your_location,
            message: Strings.your_location_will_only_be_used_for_navigation_purposes,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: Strings.go_to_settings,
                style: .default,
                handler: { _ in
                    if let bundleId = Bundle.main.bundleIdentifier,
                        let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)")
                    {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: Strings.cancel,
                style: .default,
                handler: nil
            )
        )
        return alertController
    }
}
