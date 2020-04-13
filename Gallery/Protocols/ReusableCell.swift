//
//  ReusableCell.swift
//  Gallery
//
//  Created by Jan Nemeček on 14/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

extension UICollectionView {
    func dequeueReusableCell<T: ReusableCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
