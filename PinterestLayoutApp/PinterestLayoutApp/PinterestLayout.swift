//
//  PinterestLayout.swift
//  PinterestLayoutApp
//
//  Created by Mehmet Ali Demir on 12.01.2023.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

// PinterestLayout is a custom UICollectionViewLayout subclass that provides a Pinterest-style layout for a collection view
class PinterestLayout: UICollectionViewLayout {

    weak var delegate: PinterestLayoutDelegate?


    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6

    // Array to cache the layout attributes
    private var cache: [UICollectionViewLayoutAttributes] = []

    // Variables to track the content height and width
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    // Overriding the collectionViewContentSize property to return the size of the entire collection view
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    // prepare() method is called when the layout is first created or when any changes are made to the layout
    override func prepare() {

        guard
        cache.isEmpty == true,
            let collectionView = collectionView
            else {
            return
        }
        // Calculate the column width and create an array to track the x offset for each column
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)

        // Loop through all of the items in the collection view
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            // Get the height of the photo from the delegate and calculate the frame for the cell
            let photoHeight = delegate?.collectionView(
                collectionView,
                heightForPhotoAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            // Create a UICollectionViewLayoutAttributes object and add it to the cache
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            // Update the content height and the y offset for the current column
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    // layoutAttributesForElements(in:) method returns an array of UICollectionViewLayoutAttributes objects for the items that are currently visible on the screen
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    // layoutAttributesForItem(at:) method returns the UICollectionViewLayoutAttributes object for the specified index path
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }


}
