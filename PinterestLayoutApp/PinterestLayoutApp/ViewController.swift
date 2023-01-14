//
//  ViewController.swift
//  PinterestLayoutApp
//
//  Created by Mehmet Ali Demir on 12.01.2023.
//

import UIKit

class ViewController: UIViewController {

    // heroes is an array that will hold all of the hero objects retrieved from the API
    var heroes = [Hero]()

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a URL object with the API endpoint
        let url = URL(string: "https://api.opendota.com/api/heroStats")
        // Use URLSession to retrieve data from the API
        URLSession.shared.dataTask(with: url!) { (data, response, error) in

            if error == nil {
                do {
                    self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                } catch {
                    print("Parse Error")
                }
                // Once the data is parsed, reload the collection view on the main thread
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }.resume()

        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
    }
}

// Extension to ViewController to conform to the UICollectionViewDataSource and PinterestLayoutDelegate protocols
extension ViewController: UICollectionViewDataSource, PinterestLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as? CustomCollectionViewCell {

            let defaultLink = "https://api.opendota.com"
            let completeLink = defaultLink + heroes[indexPath.row].img
            
            // Use the downloaded(from:) method to load the image from the complete link
            cell.imageView.downloaded(from: completeLink)
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 15
            cell.imageView.contentMode = .scaleAspectFill
            return cell
        }

        return UICollectionViewCell()
    }
    // Method for PinterestLayoutDelegate protocol. Returns the height of the image for the specified index path
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {

        // Create the complete link for the current hero's image
        let defaultLink = "https://api.opendota.com"
        let completeLink = defaultLink + heroes[indexPath.row].img
        let urlImage = URL(string: completeLink)

        // Try to retrieve the data from the link
        let data = try? Data(contentsOf: urlImage!)
        // Create an image from the data
        let image = UIImage(data: data!)

        if let height = image?.size.height {
            return height
        }
        return 0.0
    }
}


// Extension to UIImageView to add a convenience method for loading images from a URL
extension UIImageView {
    // Method to load image from a URL and set it to the image view
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    // Method to load image from a link string
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        // Create a URL from the link string
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
// Hero struct to hold the data for each hero retrieved from the API
struct Hero: Decodable {
    let localized_name: String
    let img: String
    
}

