//
//  UIImageView+Animation.swift
//  Gallery
//
//  Created by Jan Nemeček on 16/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImage(_ image: UIImage?, animated: Bool) {
        guard animated else {
            self.image = image
            return
        }
        UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
}
