//
//  Statistics.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/23/22.
//

import UIKit

class StatisticsViewController: UITableViewController{
    var highscoreAltered = false
    var foundList = [WordItem]()
    var missedList = [WordItem]()
    var wordsFound = 0
    var wordsMissed = 0
    var score = 0
    var highscore = 0
    var scoreDifference = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        wordsFound = foundList.count
        wordsMissed = missedList.count
        updateLabels()
    }
    
    // MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.row{
        case 2:
            return indexPath
        case 3:
            return indexPath
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WordListsViewController{
            let controller = segue.destination as! WordListsViewController
            controller.title = segue.identifier
            if segue.identifier == "wordsFound"{
                controller.wordsList = foundList
                controller.title = "Words Found"
            } else if segue.identifier == "wordsMissed"{
                controller.wordsList = missedList
                controller.title = "Words Missed"
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func close(){
        self.navigationController?.popToRootViewController(animated: true)
        // CITE STACKOVERFLOW; this is used to return to the first screen
    }
    
    // MARK: - Outlets
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var wordsFoundLabel: UILabel!
    @IBOutlet weak var wordsMissedLabel: UILabel!
    
    func updateLabels(){
        scoreLabel.text! = String(score)
        if (highscoreAltered){
            highscoreLabel.text! = "New High Score:  \(highscore)"
        } else{
            highscoreLabel.text! = "High Score:  \(highscore)"
        }
        showHighScore()
        wordsFoundLabel.text! = " \(wordsFound)/\(wordsFound+wordsMissed)"
        
        wordsMissedLabel.text! = " \(wordsMissed)/\(wordsFound+wordsMissed)"
    }
    
    func showHighScore() {
        var alertTitle = "High Score Update"
        var message = "Your High Score Did Not Change"
        if highscore-score < 600 && highscore-score != 0{
            alertTitle = "So Close!"
            message = "You were \(highscore-score) points away from beating your high score!"
        } else if highscoreAltered{
            alertTitle = "New High Score"
            message = "Congratulations! You beat your high score by \(scoreDifference)"
        } else if highscore-score > 600 && highscore-score <= 2000{
            alertTitle = "Better Luck Next Time!"
            message = "Try to coming up with more words next time!"
        }else if highscore-score > 2000 && score != 0{
            alertTitle = "Seriously?"
            message = "You were not even close to beating your high score..."
        }
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.view.tintColor = UIColor.init(named: "AccentColor")
        let action = UIAlertAction(title: "Okay!", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
