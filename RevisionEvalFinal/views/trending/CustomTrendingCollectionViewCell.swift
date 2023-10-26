//
//  CustomTrendingCollectionViewCell.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 21/10/2023.
//

import UIKit

class CustomTrendingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var rateBackCircle: UIView!
    @IBOutlet var rateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        movieImage.layer.cornerRadius = 5
        
        rateBackCircle.layer.cornerRadius = rateBackCircle.frame.width / 2
        rateBackCircle.layer.borderWidth = 1
        rateBackCircle.layer.borderColor = UIColor.red.cgColor
    }

}
