//
//  MovieCell.swift
//  Flicks
//
//  Created by Pooja Chowdhary on 3/31/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var MovieLabel: UILabel!
    @IBOutlet weak var MovieOverviewLabel: UILabel!
    @IBOutlet weak var MovieImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
