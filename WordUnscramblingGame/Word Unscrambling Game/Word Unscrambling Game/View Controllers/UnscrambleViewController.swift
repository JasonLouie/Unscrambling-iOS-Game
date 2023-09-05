//
//  UnscrambleViewController.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/23/22.
//

import UIKit

class UnscrambleViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, OptionsPopUpViewControllerDelegate {
    func optionViewControllerDidReset(_ controller: OptionsPopUpViewController, didResetAll reset: Bool) {
        if reset{
            dataModel.gameData.userFirstTime()
            dataModel.shouldResetData = true
            dataModel.optionsResetRound = false
            dataModel.randomBounds = false
        }
        navigationController?.popViewController(animated: true)
    }
    
    func optionViewControllerDidCancel(_ controller: OptionsPopUpViewController, didCancelChanges change: Bool) {
        wasCancelled = change
        navigationController?.popViewController(animated: true)
    }
    
    func optionViewController(_ controller: OptionsPopUpViewController, didUpdateBounds bound: Int, didUpdateAnswerSize newSize: Int, didUpdateRandomize randomize: Bool, didUpdateResetData reset: Bool, didCancelChanges change: Bool) {
        
        // Update settings
        dataModel.gameData.wordBound = bound
        dataModel.gameData.minimumWordSize = newSize
        dataModel.randomBounds = randomize
        dataModel.optionsResetRound = reset
        wasCancelled = change

        
        // Animate options saved
        guard let mainView = controller.parent?.view
        else{ return }
        let hudView = OptionsHudView.hud(inView: mainView, animated: true)
        hudView.text = "Saved"
        let delayInSeconds = 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds){
            hudView.hide()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    var wasCancelled = true
    var dataModel: DataModel!
    let headerTitles = ["Scores", "Words Found"]
    var initialGameTableViewHeight: CGFloat = 0
    
    override func viewDidLoad(){
        navigationItem.largeTitleDisplayMode = .never
        super.viewDidLoad()
        
        // Hides keyboard when user touches an area outside of the keyboard. The objc function hideKeyboard is part of the implementation.
        // Citation: https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
        // Edited and used the code to hide the keyboard when user touches anywhere outside rather than being hidden when the area touched is not a tableview cell.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        gametableView.addGestureRecognizer(gestureRecognizer)
        
        /*
        Referred to various stackoverflow threads on how to move answerView and eventually implemented the addition of two observers.
         https://stackoverflow.com/questions/31774006/how-to-get-height-of-keyboard
        In objc functions keyboardWillShow and keyboardWillHide, I change the height of the gametableView since I used constraints to bound the answerView to the bottom of gametableView. Changing the height allows answerView to "move" up and down.
        */
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialGameTableViewHeight = gametableView.frame.height
        updateWordCount()
        dataModel.showKeyBoard = true
        navigationController?.delegate = self
        let generateNewData = dataModel.shouldResetData
        let optionsResetRound = dataModel.optionsResetRound
        // Logic here is new data is generated only when the user default dictates it (after an end round is initiated) or whenever user updates options and options actually changed.
        if generateNewData || (optionsResetRound && !wasCancelled){
            title = "Fetching new word..."
            wordsFound.text! = "Loading..."
            dataModel.gameData.restartRound()
            generateWord()
            gametableView.reloadData()
        } else{
            title = "Unscramble: \(dataModel.gameData.scrambledword)"
        }
    }
    
    // MARK: - TableViewDataSource Delegates
    // Update cells for scoreboard (section 0) and list of words found (section 1)
    func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Unscramble", for: indexPath)
        if indexPath.section == 0{
            if indexPath.row == 0{
                cell.textLabel!.text = "Score:  \(dataModel.gameData.score)"
            } else if indexPath.row == 1{
                cell.textLabel!.text = "Highscore:  \(dataModel.gameData.highscore)"
            }
        } else if indexPath.section == 1{
            cell.textLabel!.text = dataModel.gameData.foundList[indexPath.row].word
        }
        return cell
    }
    
    // Set number of rows for scoreboard (section 0) and list of words found (section 1)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 2
        case 1:
            return dataModel.gameData.foundList.count
        default: return 1
        }
    }
    
    // Number of sections depend on number of header titles
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
    }
    
    // Sets name of each section using the array headerTitles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        return nil
    }
    
    // MARK: - NavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // If the last view controller to be accessed is UnscrambleViewController, persist data.
        if viewController === self {
            dataModel.shouldResetData = false
        }
    }
    
    // Send values over to StatisticsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is StatisticsViewController{
            let controller = segue.destination as! StatisticsViewController
            let dataOfGame = dataModel.gameData
            controller.foundList = dataOfGame.foundList
            controller.missedList = dataOfGame.missedList
            controller.score = dataOfGame.score
            controller.highscore = dataOfGame.highscore
            controller.highscoreAltered = dataOfGame.highscoreAltered
            controller.scoreDifference = dataOfGame.scoreDifference
        } else if segue.destination is OptionsPopUpViewController{
            let controller = segue.destination as! OptionsPopUpViewController
            controller.delegate = self
            controller.bound = dataModel.gameData.wordBound
            controller.wordSize = dataModel.gameData.minimumWordSize
            controller.wordSizeRandomize = dataModel.randomBounds
            controller.resetRound = dataModel.optionsResetRound
        }
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var gametableView: UITableView!
    @IBOutlet var answerView: UIView!
    @IBOutlet weak var wordsFound: UILabel!
    //MARK: - Actions
    
    @IBAction func reset(){
        // Clear user input
        emptyUserInput()
        enterButton.isEnabled = false
        resetButton.isEnabled = false
    }
    
    @IBAction func showAlert() {
        let helpAlert = UIAlertController(title: "Instructions", message: "Create as many words as you can from the scrambled word", preferredStyle: .alert)
        helpAlert.view.tintColor = UIColor.init(named: "AccentColor")
        let action = UIAlertAction(title: "Got it!", style: .default, handler: nil)
        
        helpAlert.addAction(action)
        present(helpAlert, animated: true, completion: nil)
    }
    
    // Changes UserDefault for ResetData to true so that the next time UnscrambleViewController is first, a new round will begin since user already finished current round.
    @IBAction func endRound(){
        let endRoundAlert = UIAlertController(title: "End Round", message: "Are you sure you want to end the round?", preferredStyle: .alert)
        endRoundAlert.view.tintColor = UIColor.init(named: "AccentColor")
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            self.dataModel.shouldResetData = true
            self.performSegue(withIdentifier: "ShowStats", sender: self)
        })
        endRoundAlert.addAction(no)
        endRoundAlert.addAction(yes)
        present(endRoundAlert, animated: true, completion: nil)
    }

    
    // When pressed, check if the user's answer is valid. A valid answer is an entry for foundList that exists in possibleWords, but is not already in foundList.
    @IBAction func enter(){
        let userInputText = userInput.text!
        if (!checkIfInFoundList(userInputText) && userInputText.count >= dataModel.gameData.minimumWordSize && isAnAnswer(userInputText)){
            let someWord = WordItem()
            someWord.word = userInputText
            someWord.points = calculatePoints(userInputText)
            dataModel.gameData.foundList.append(someWord)
            dataModel.gameData.score+=(someWord.points)
            updateMissedList(userInputText)
            let indexPath = IndexPath(row: dataModel.gameData.foundList.count-1, section: 1)
            gametableView.insertRows(at: [indexPath], with: .automatic)
            scrollToBottom()
            updateScores()
            updateWordCount()
        }
        if dataModel.gameData.missedList.isEmpty{
            let endRoundAlert = UIAlertController(title: "Round Complete!", message: "You found all of the words!", preferredStyle: .alert)
            endRoundAlert.view.tintColor = UIColor.init(named: "AccentColor")
            let yes = UIAlertAction(title: "Yay!", style: .default, handler: {(action: UIAlertAction!) in
                self.dataModel.shouldResetData = true
                self.performSegue(withIdentifier: "ShowStats", sender: self)
            })
            endRoundAlert.addAction(yes)
            present(endRoundAlert, animated: true, completion: nil)
        }
        emptyUserInput()
        enterButton.isEnabled = false
    }
    
    @IBAction func showOptions(){
        userInput.resignFirstResponder()
        dataModel.showKeyBoard = false
    }
    
    // MARK: - Objective C Functions
    @objc func hideKeyboard( _ gestureRecognizer: UIGestureRecognizer){
        userInput.resignFirstResponder()
    }
    
    // Added UserDefault for showing keyboard since the keyboard would "show" when testing and gametableView would resize when keyboard is not truly shown.
    @objc func keyboardWillShow(sender: NSNotification) {
        if dataModel.showKeyBoard{
            if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                // difference is the height of the remaining part of the entire viewcontroller
                let difference = self.view.frame.size.height - initialGameTableViewHeight
                // Resize gametableView height to move answerView up
                // Only works because answerView's top constraint is equivalent to gametableView's bottom
                // difference-height of answerView represents the height of the area that is not taken up by gametableView and answerView
                self.gametableView.frame.size.height = initialGameTableViewHeight - (keyboardHeight-(difference-answerView.frame.size.height))
            }
            
            // Scroll to the bottom of gametableView
            if !self.dataModel.gameData.foundList.isEmpty{
                self.scrollToBottom()
            }
            dataModel.showKeyBoard = false
        }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        dataModel.showKeyBoard = true
        self.gametableView.frame.size.height = initialGameTableViewHeight
    }
    
    // MARK: - Helper Functions
    // Generates a random word from API that is as short as dataModel.gameData.lowerBound and as long as dataModel.gameData.upperBound. Calls function generateAnswer() immediately after the new word is generated. The word is scrambled within class UnscrambleAPI.
    func generateWord(){
        let bound = dataModel.gameData.wordBound
        let randomize = dataModel.randomBounds
        RandomWordAPI.RandomWordAPIInstance.generateWord(bound,randomize) { newWord in
            DispatchQueue.main.async {
                if newWord != nil {
                    self.dataModel.gameData.scrambledword = RandomWordAPI.RandomWordAPIInstance.word.uppercased()
                    self.title = "Unscramble: \(self.dataModel.gameData.scrambledword)"
                    self.generateAnswers()
                } else {
                    self.dataModel.gameData.scrambledword = "ERROR"
                }
            }
        }
    }
    
    // Calls the Unscramble API to generate acceptable answers, then initializes missedList in DataModel with all these answers.
    func generateAnswers(){
        let dataOfGame = dataModel.gameData
        UnscrambleAPI.UnscrambleAPIInstance.unscrambleWord(dataOfGame.scrambledword.lowercased()) { answers in
            DispatchQueue.main.async {
                if answers != nil{
                    dataOfGame.possibleWords = UnscrambleAPI.UnscrambleAPIInstance.possibleWords
                    self.initializeMissedList()
                    self.updateWordCount()
                }
            }
        }
    }
    
    // Updates user scores
    func updateScores(){
        let dataOfGame = dataModel.gameData
        if dataOfGame.score > dataOfGame.highscore{
            dataOfGame.highscoreAltered = true
            dataOfGame.scoreDifference += (dataOfGame.score-dataOfGame.highscore)
            dataOfGame.highscore = dataOfGame.score
        }
        
        // Append the two table cell rows containing score and highscore to reloadScores and then notify gametableView to reload those rows so that the new values are displayed.
        var reloadScores = [IndexPath]()
        for cell in gametableView.visibleCells {
            let indexPath: IndexPath = gametableView.indexPath(for: cell)!
            if indexPath.section == 0 {
                reloadScores.append(indexPath)
            }
        }
        gametableView.reloadRows(at: reloadScores, with: .none)
    }
    
    func updateWordCount(){
        let dataOfGame = dataModel.gameData
        wordsFound.text! = "Words Found:  \(dataOfGame.foundList.count)/\(dataOfGame.missedList.count+dataOfGame.foundList.count)"
    }
    
    func emptyUserInput(){
        userInput.text! = ""
        resetButton.isEnabled = false
    }
    
    // Retuns true if in foundList, false if it isn't
    func checkIfInFoundList(_ text: String) -> Bool{
        for word in dataModel.gameData.foundList{
            if text == word.word{
                return true
            }
        }
        return false
    }
    
    // Returns true if text is a valid input
    func isAnAnswer(_ text: String) -> Bool{
        for someword in dataModel.gameData.possibleWords{
            if text == someword.word!{
                return true
            } else if text.count > someword.word!.count{
                // No need to make any other comparisons since this cannot be a valid answer seeing as the size of text is greater than someword
                return false
            }
        }
        return false
    }
    
    // Calculate the points per letter of text
    // Used the basic scrabble point system per letter but times 10
    func calculatePoints(_ text: String) -> Int{
        var pointsAwarded = text.count*10
        for char in text{
            if (char == "A" || char == "E" || char == "I" || char == "L" || char == "N" || char == "O" || char == "R" || char == "S" || char == "T" || char == "U"){
                pointsAwarded+=10
            } else if (char == "D" || char == "G"){
                pointsAwarded+=20
            } else if (char == "B" || char == "C" || char == "M" || char == "P"){
                pointsAwarded+=30
            } else if (char == "F" || char == "H" || char == "V" || char == "W" || char == "Y"){
                pointsAwarded+=40
            } else if (char == "K"){
                pointsAwarded+=50
            } else if (char == "J" || char == "X"){
                pointsAwarded+=80
            } else if (char == "Q" || char == "Z"){
                pointsAwarded+=100
            }
        }
        return pointsAwarded
    }
    
    // Essentially, set missedList = possibleWords to assume the user missed all words, then remove words from missedList using updateMissedList whenever a valid answer is entered.
    func initializeMissedList(){
        let dataOfGame = dataModel.gameData
        for someWord in dataOfGame.possibleWords{
            if someWord.word!.count >= dataOfGame.minimumWordSize{
                let wordEntry = WordItem()
                wordEntry.word = someWord.word!
                wordEntry.points = calculatePoints(someWord.word!)
                dataOfGame.missedList.append(wordEntry)
            }
        }
    }
    
    // Remove the valid word that user found from the missedList
    func updateMissedList(_ word: String) {
        let wordsMissed = dataModel.gameData.missedList.count
        for i in 0..<wordsMissed{
            if word == dataModel.gameData.missedList[i].word{
                dataModel.gameData.missedList.remove(at: i)
                return
            }
        }
    }
    
    // Scrolls to the bottom of gametableView after a new word is added
    // See citation in viewDidLoad
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.dataModel.gameData.foundList.count-1, section:1)
            self.gametableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Text Field Delegates
    // Do not permit input to exceed size of scrambledword and update if enterButton.isEnabled depending on size of user input.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        enterButton.isEnabled = !newText.isEmpty
        resetButton.isEnabled = !newText.isEmpty
        return newText.count <= dataModel.gameData.scrambledword.count
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        enterButton.isEnabled = false
        return true
    }
    
    // There was an issue with the done button not functioning when the user input was the same size as scrambledword, so whether done is enabled equals to enterButton.isEnabled
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return enterButton.isEnabled
    }
}
