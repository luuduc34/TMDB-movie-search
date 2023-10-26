//
//  CustomTableViewCell.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 20/10/2023.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateBackCircle: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
             
        rateBackCircle.layer.cornerRadius = rateBackCircle.frame.width / 2
        rateBackCircle.layer.borderWidth = 1
        rateBackCircle.layer.borderColor = UIColor.red.cgColor
        rateBackCircle.backgroundColor = .clear
    }
    @IBAction func favoriteBtn() {
        
    }
    
}
