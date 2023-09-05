//
//  WordListCell.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/24/22.
//

import UIKit

class WordListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    
    func configure(for word: WordItem){
        wordLabel.text = word.word
        pointsLabel.text = "\(word.points) points"
    }
}
