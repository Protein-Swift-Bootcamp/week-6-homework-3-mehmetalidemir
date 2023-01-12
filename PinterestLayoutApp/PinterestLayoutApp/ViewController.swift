//
//  ViewController.swift
//  PinterestLayoutApp
//
//  Created by Mehmet Ali Demir on 12.01.2023.
//

import UIKit

class ViewController: UIViewController {

    let photos = [1, 2, 3, 4, 5, 6, 7]

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
    }
}

extension ViewController: UICollectionViewDataSource, PinterestLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as? CustomCollectionViewCell {

            cell.imageView.image = UIImage(named: "\(photos[indexPath.row]).png")
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 15
            cell.imageView.contentMode = .scaleAspectFill
            return cell
        }

        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {

        let image = UIImage(named: "\(photos[indexPath.row]).png")

        if let height = image?.size.height {
            return height / 4
        }
        return 0.0
    }
}
