//
//  WordsListViewController.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/23/22.
//

import UIKit
class WordListsViewController: UITableViewController{
    
    var wordsList = [WordItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.tintColor = UIColor.init(named: "AccentColor")
        navigationItem.largeTitleDisplayMode = .never
    }
    // MARK: - Table View Delegates
    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsList.count
    }
    
    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> WordListCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath) as! WordListCell
        let word = wordsList[indexPath.row]
        cell.configure(for: word)
        return cell
    }
    
    override func tableView( _ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?{
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WordInfoViewController{
            let controller = segue.destination as! WordInfoViewController
            
            // Configure WordInfoViewController's title to display info on a specific word
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                let word = wordsList[indexPath.row]
                controller.word = word.word
                controller.title = "Information on \(word.word)"
            }
            
        }
    }
}
