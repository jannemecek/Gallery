//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var viewModel: GalleryCollectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = GalleryCollectionViewModel(collectionView: collectionView)
        viewModel.loadImages()
        collectionView.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func addTapped(_ sender: Any) {
        // TODO: initiate add process
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is PhotoDetailViewController:
            guard let vc = segue.destination as? PhotoDetailViewController,
                let cell = sender as? UICollectionViewCell,
                let indexPath = collectionView.indexPath(for: cell) else { return }
            vc.image = viewModel.image(at: indexPath)
        default:
            break
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsToFit: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            cellsToFit = 6
        default:
            cellsToFit = 3
        }
        let width: CGFloat = (view.safeAreaLayoutGuide.layoutFrame.width-cellsToFit)/cellsToFit
        return CGSize(width: width, height: width)
    }
}
