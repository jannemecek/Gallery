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
    private let imageLoader = ImageLoader.shared
    private var disposable: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposable?.cancel()
    }
    
    private func setup() {
        disposable = imageLoader.loadImage(image, into: imageView, animated: false)
        descriptionLabel.text = image.comment
    }
    
    // MARK: - Actions
    
    @IBAction private func shareTapped(_ sender: UIBarButtonItem) {
        sender.isEnabled.toggle()
        disposable = imageLoader.loadImage(image) { [weak self] (image) in
            sender.isEnabled.toggle()
            let vc = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)
            vc.popoverPresentationController?.barButtonItem = sender
            self?.present(vc, animated: true, completion: nil)
        }
    }
}
