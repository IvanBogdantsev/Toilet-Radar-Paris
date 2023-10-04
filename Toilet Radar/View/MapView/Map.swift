//
//  Map.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 01.12.2022.
//

import MapboxMaps
import RxSwift
import RxCocoa

final class Map: MapView {
    
    init(frame: CGRect) {
        let style = UIScreen.main.traitCollection.userInterfaceStyle == .light ? StyleURI.outdoors : StyleURI.dark
        let initOptions = MapInitOptions(resourceOptions: MapBoxConstants.resourceOptions,
                                         cameraOptions: MapBoxConstants.cameraLaunchOptions,
                                         styleURI: style)
        super.init(frame: frame, mapInitOptions: initOptions)
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // configuring a 2-dimensional puck with heading indicator
        let puckConfiguration = Puck2DConfiguration.makeDefault(showBearing: true)
        location.options.puckType = .puck2D(puckConfiguration)
    }
    
    @available(iOSApplicationExtension, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

