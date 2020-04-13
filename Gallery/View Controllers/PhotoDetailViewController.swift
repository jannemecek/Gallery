//
//  PhotoDetailViewController.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    var image: Image!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ImageLoader.shared.loadImage(image) { [weak self] (image) in
            self?.imageView.image = image
        }
        descriptionLabel.text = image.comment
    }
    
    // MARK: - Actions
    
    @IBAction func shareTapped(_ sender: Any) {
        // TODO: prevent multiple taps
        // TODO: separate out share functionality
        ImageLoader.shared.loadImage(image) { [weak self] (image) in
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self?.present(vc, animated: true, completion: nil)
        }
    }
}
