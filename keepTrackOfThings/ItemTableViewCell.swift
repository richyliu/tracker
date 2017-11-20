//
//  ItemTableViewCell.swift
//  mealExample
//
//  Created by Xiaolan Zhou on 10/28/17.
//  Copyright © 2017 Richard Liu. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    // MARK: Properties
    // used by ItemTableViewController when creating table cells/rows
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
