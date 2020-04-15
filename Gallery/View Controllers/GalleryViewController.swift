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
    @IBOutlet weak var addButton: UIBarButtonItem!
    private var viewModel: GalleryCollectionViewModel!
    private let sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = GalleryCollectionViewModel(collectionView: collectionView)
        collectionView.delegate = self
        addButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(sourceType)
    }
    
    // MARK: - Actions
    
    @IBAction func addTapped(_ sender: Any) {
        // TODO: initiate add process
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
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

// MARK: - UIImagePickerControllerDelegate

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        viewModel.insertImage(pickedImage)
    }
}
