//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/16/20.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // Photo Alpha
    let PHOTO_LOADING_ALPHA = CGFloat(0.5)
    
    override func awakeFromNib() {
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
    }
        
    // MARK: Loading show/hide helpers
    func showLoading() {
        self.activityIndicator.startAnimating()
        self.photo.alpha = PHOTO_LOADING_ALPHA
    }
        
    func hideLoading() {
        self.activityIndicator.stopAnimating()
        self.photo.alpha = 1
    }
        
    // MARK: Prepare for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = UIImage(named: "placeholder")
        self.showLoading()
    }
    
}
