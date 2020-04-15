//
//  CGSize+Image.swift
//  Gallery
//
//  Created by Jan Nemeček on 15/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

extension CGSize {
    func aspectFillSize(_ size: CGSize) -> CGSize {
        let scaleWidth = size.width / self.width
        let scaleHeight = size.height / self.height
        let scale = max(scaleWidth, scaleHeight)

        let resultSize = CGSize(width: self.width * scale, height: self.height * scale)
        return CGSize(width: ceil(resultSize.width), height: ceil(resultSize.height))
    }
}
