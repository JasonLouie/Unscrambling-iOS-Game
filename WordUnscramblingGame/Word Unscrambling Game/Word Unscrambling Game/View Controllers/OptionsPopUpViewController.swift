//
//  OptionsPopUpViewController.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 5/6/22.
//

import UIKit
protocol OptionsPopUpViewControllerDelegate: AnyObject {
    func optionViewControllerDidCancel(_ controller: OptionsPopUpViewController, didCancelChanges change: Bool)
    func optionViewController(_ controller: OptionsPopUpViewController, didUpdateBounds bound: Int, didUpdateAnswerSize newSize: Int, didUpdateRandomize randomize: Bool, didUpdateResetData reset: Bool, didCancelChanges change: Bool)
    func optionViewControllerDidReset(_ controller: OptionsPopUpViewController, didResetAll reset: Bool)
}

class OptionsPopUpViewController: UIViewController{
    var bound = 0
    var wordSize = 0
    var newBound = 0
    var newWordSize = 0
    var wordSizeRandomize = false
    var newWordSizeRandomize = false
    var newResetRound = false
    var resetRound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateValues()
        updateRandomize()
        updateRoundReset()
    }
    
    weak var delegate: OptionsPopUpViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var boundValue: UILabel!
    @IBOutlet var wordSizeValue: UILabel!
    @IBOutlet var boundSlider: UISlider!
    @IBOutlet var boundText: UILabel!
    @IBOutlet var wordSizeSlider: UISlider!
    @IBOutlet var wordSizeRandomButton: UIButton!
    @IBOutlet var resetRoundButton: UIButton!
    
    // MARK: - Actions
    @IBAction func toggleRandomWordSize() {
        newWordSizeRandomize.toggle()
        updateRandomize()
        updateDoneButton()
    }
    
    @IBAction func toggleResetRound() {
        newResetRound.toggle()
        updateRoundReset()
        updateDoneButton()
    }
    
    @IBAction func boundsliderMoved(_ slider: UISlider) {
        newBound = lroundf(slider.value)
        boundValue.text = "\(newBound)"
        updateDoneButton()
    }
    
    @IBAction func wordSizesliderMoved(_ slider: UISlider) {
        newWordSize = lroundf(slider.value)
        wordSizeValue.text = "\(newWordSize)"
        updateDoneButton()
    }
    
    @IBAction func cancel(){
        delegate?.optionViewControllerDidCancel(self, didCancelChanges: true)
    }
    
    @IBAction func done(){
        var message = ""
        if newBound != bound{
            message+="Scrambled Size: \(bound) --> \(newBound)"
        }
        if newWordSize != wordSize{
            if !message.isEmpty{
                message+="\n"
            }
            message+="Answer Size: \(wordSize) --> \(newWordSize)"
        }
        if newWordSizeRandomize != wordSizeRandomize{
            var enabled = "Disabled"
            if newWordSizeRandomize{
                enabled = "Enabled"
            }
            if !message.isEmpty{
                message+="\n"
            }
            message+="Randomize Scrambled Size: \(enabled)"
        }
        if newResetRound != resetRound{
            var enabled = "Disabled"
            if newResetRound{
                enabled = "Enabled"
            }
            if !message.isEmpty{
                message+="\n"
            }
            message+="Reset on Update: \(enabled)"
        }
        
        let updateOptionsAlert = UIAlertController(title: "Save Changes?", message: message, preferredStyle: .alert)
        updateOptionsAlert.view.tintColor = UIColor.init(named: "AccentColor")
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            self.delegate?.optionViewController(self, didUpdateBounds: self.newBound, didUpdateAnswerSize: self.newWordSize, didUpdateRandomize: self.newWordSizeRandomize, didUpdateResetData: self.newResetRound, didCancelChanges: false)
        })
        updateOptionsAlert.addAction(no)
        updateOptionsAlert.addAction(yes)
        present(updateOptionsAlert, animated: true, completion: nil)
    }
    
    @IBAction func resetAllData(){
        let resetAllDataAlert = UIAlertController(title: "Reset ALL Data?", message: "WARNING: This cannot be undone!", preferredStyle: .alert)
        resetAllDataAlert.view.tintColor = UIColor.init(named: "AccentColor")
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            self.delegate?.optionViewControllerDidReset(self, didResetAll: true)
        })
        resetAllDataAlert.addAction(no)
        resetAllDataAlert.addAction(yes)
        present(resetAllDataAlert, animated: true, completion: nil)
    }
    
    func updateDoneButton(){
        if ( (bound == newBound && wordSize == newWordSize && wordSizeRandomize == newWordSizeRandomize && resetRound == newResetRound) || newWordSize > newBound){
            doneButton.isEnabled = false
        }else{
            doneButton.isEnabled = true
        }
    }
    
    func updateValues(){
        newBound = bound
        newWordSize = wordSize
        newWordSizeRandomize = wordSizeRandomize
        newResetRound = resetRound
        boundValue.text = String(bound)
        wordSizeValue.text = String(wordSize)
        boundSlider.value = Float(bound)
        wordSizeSlider.value = Float(wordSize)
    }
    
    func updateRandomize(){
        if newWordSizeRandomize{
            wordSizeRandomButton.configuration?.title = "√"
            wordSizeRandomButton.configuration?.background.backgroundColor = UIColor.init(named: "AccentColor")
        } else{
            wordSizeRandomButton.configuration?.title = ""
            wordSizeRandomButton.configuration?.background.backgroundColor = .clear
        }
        boundSlider.isEnabled = !newWordSizeRandomize
        boundValue.isEnabled = !newWordSizeRandomize
        boundText.isEnabled = !newWordSizeRandomize
    }
    
    func updateRoundReset(){
        if newResetRound{
            resetRoundButton.configuration?.title = "√"
            resetRoundButton.configuration?.background.backgroundColor = UIColor.init(named: "AccentColor")
        } else{
            resetRoundButton.configuration?.title = ""
            resetRoundButton.configuration?.background.backgroundColor = .clear
        }
    }
}
