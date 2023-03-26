//
//  ShowMyLocationButton.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 26.03.2023.
//

import UIKit

final class ShowMyLocationButton: UIButton {
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.locationArrow
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .prlBlue
        return imageView
    }()
    
    private let dimensionAnchor: CGFloat = 60
    private var cornerRadius: CGFloat {
        dimensionAnchor / 2
    }
    // ensuring the icon within the button as an incsribed square since the button is a circle with dimensionAnchor diameter. Won't be going anywhere
    private var iconDimensionAnchor: CGFloat {
        dimensionAnchor / 1.414 
    }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupAppearance()
        setupIcon()
    }
    
    private func setupAppearance() {
        backgroundColor = .white
        heightAnchor.constraint(equalToConstant: dimensionAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: dimensionAnchor).isActive = true
        layer.cornerRadius = cornerRadius
    }
    
    private func setupIcon() {
        addSubview(icon)
        icon.heightAnchor.constraint(equalToConstant: iconDimensionAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: iconDimensionAnchor).isActive = true
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.scalexyBy(0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
