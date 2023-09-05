//
//  WordInfoViewController.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/24/22.
//

import UIKit

// Citation: https://stackoverflow.com/questions/24200888/any-way-to-replace-characters-on-swift-string
// Used amin's implementation of the string extension, but edited the if condition since declaring and using int i is not necessary.
extension String{
    func replace(_ dictionary: [String: String]) -> String{
        var result = String()
        for (of, with): (String, String) in dictionary{
            if result.isEmpty{
                result = self.replacingOccurrences(of: of, with: with)
            } else{
                result = result.replacingOccurrences(of: of, with: with)
            }
        }
        return result
    }
}

// Citation: https://stackoverflow.com/questions/26306326/swift-apply-uppercasestring-to-only-the-first-letter-of-a-string/40933056#40933056
// See Leo Dabus's response.
extension StringProtocol{
    var firstUppercased: String{
        return prefix(1).uppercased() + dropFirst()
    }
}

class WordInfoViewController: UITableViewController {
    var word = ""
    var wordDefinitions = [String]()
    var wordSynonyms = [String]()
    var wordSpeeches = [String]()
    var wordSentences = [String]()
    var dataOfWord = [DictionaryResultInnerArray]()
    
    let headers = ["content-type": "application/json","X-RapidAPI-Host": "xf-english-dictionary1.p.rapidapi.com","X-RapidAPI-Key": "9dcabfb453msh07c73ebd795a4bap1e1175jsn39e71811e6af"]
    
    let headerTitles = ["Definitions", "Synonyms", "Sentences", "Parts of Speech"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem?.tintColor = UIColor.init(named: "AccentColor")
        generateWordInfo()
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return wordDefinitions.count
        case 1:
            if !wordSynonyms.isEmpty{
                return wordSynonyms.count
            }
            return 1
        case 2:
            if !wordSynonyms.isEmpty{
                return wordSentences.count
            }
            return 1
        case 3:
            return wordSpeeches.count
        default:
            return 1
        }
    }
    
    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Information", for: indexPath)
        cell.textLabel!.lineBreakMode = .byWordWrapping
        cell.textLabel!.numberOfLines = 10
        if indexPath.section == 0{
            cell.textLabel!.text = wordDefinitions[indexPath.row]
        } else if indexPath.section == 1{
            if !wordSynonyms.isEmpty{
                cell.textLabel!.text = wordSynonyms[indexPath.row]
                //print("\nIndex: \(indexPath.row), Synonym: \(wordSynonyms[indexPath.row])")
            } else{
                cell.textLabel!.text = "No synonyms found"
            }
        } else if indexPath.section == 2{
            if !wordSentences.isEmpty{
                cell.textLabel!.text = wordSentences[indexPath.row]
                //print("\nIndex: \(indexPath.row), Sentence: \(wordSentences[indexPath.row])")
            } else{
                cell.textLabel!.text = "No sentences found"
            }
        } else if indexPath.section == 3{
            cell.textLabel!.text = wordSpeeches[indexPath.row]
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        return nil
    }
    
    func generateWordInfo(){
        // Generate info of word
        DictionaryAPI.DictionaryAPIInstance.infoOfWord(word.lowercased()) { wordInfo in
            DispatchQueue.main.async {
                if wordInfo != nil{
                    self.dataOfWord = DictionaryAPI.DictionaryAPIInstance.dataOfWord
                    self.updateAllData()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // Filters strange symbols and most citations from given line. Very rare cases such as quotes from Shakespeare and textbooks may still include citations. Also capitalizes the beginning of each line since some definitions began lowercased. Sometimes, synonyms may have too many white spaces in between one another.
    // Citation: https://stackoverflow.com/questions/27226128/what-is-the-more-elegant-way-to-remove-all-characters-after-specific-character-i
    
    func filterSymbols(_ line: String) -> String{
        let keys = ["<b>": "", "[...]": "", "</b>": "", "<i>": "", "</i>": ""]
        var newline = line.replace(keys)
        
        // Case for strange occurances such as '(<b> sometext </b>) Information...' when only 'Information...' is wanted. NOTE: <b> and </b> are removed in the previous two lines, but the initial case was ^. Those symbols are removed because some data had those symbols embedded within definitions, synonyms, and sentences. Example: 'This is a definition with a <b> lot </b> of helpful information.'
        if newline[newline.startIndex] == "("{
            if let index = newline.range(of: ")")?.upperBound{
                let indexAfter = newline.index(after:index)
                newline = String(newline.suffix(from:indexAfter))
                // Case: '(<b> sometext </b>): Information...' After both removals, this will be 'Information...'
                if newline[newline.startIndex] == ":"{
                    let indexAfter = newline.index(after:newline.startIndex)
                    newline = String(newline.suffix(from:indexAfter))
                }
            }
        }
        
        // Case for line containing citations, which start with an int. Citations end with 3 difference characters. Example: '2014, Place Where Sentence is Quoted From: Sentence begins.' As mentioned earlier, on rare occassions while testing sentences, some citations skipped these cases.
        if newline[newline.startIndex].wholeNumberValue != nil{
            if let index = newline.range(of: ":")?.upperBound{
                let indexAfter = newline.index(after:index)
                return String(newline.suffix(from:indexAfter))
            } else{
                if let index = newline.range(of: "—")?.upperBound{
                    let indexAfter = newline.index(after:index)
                    newline = String(newline.suffix(from:indexAfter))
                } else{
                    if let index = newline.range(of: "-")?.upperBound{
                        let indexAfter = newline.index(after:index)
                        newline = String(newline.suffix(from:indexAfter))
                    }
                }
            }
        }
        // Citation: https://stackoverflow.com/questions/28570973/how-should-i-remove-all-the-leading-spaces-from-a-string-swift
        // Remove whitespaces in the beginning of information
        if newline[newline.startIndex] == " "{
            newline = newline.trimmingCharacters(in: .whitespaces)
        }
        newline = newline.firstUppercased
        
        return newline
    }
    
    func updateAllData(){
        for def in dataOfWord{
            if !def.definitions.isEmpty{
                for defs in def.definitions{
                    if defs.definition != "None"{
                        let itemToAppend = filterSymbols(defs.definition!)
                        if itemToAppend.count > 1{
                            wordDefinitions.append(itemToAppend)
                        }
                    }
                    if let sentence = defs.examples, !sentence.isEmpty{
                        for sentences in sentence{
                            let itemToAppend = filterSymbols(sentences)
                            if itemToAppend.count > 1{
                                wordSentences.append(itemToAppend)
                            }
                        }
                    }
                }
            }
            if let value = def.synonyms, !value.isEmpty{
                for synonym in def.synonyms!{
                    let itemToAppend = filterSymbols(synonym)
                    if itemToAppend.count > 1{
                        wordSynonyms.append(itemToAppend)
                    }
                }
            }
            if let speech = def.partOfSpeech, speech != ""{
                wordSpeeches.append(speech.firstUppercased)
            }
        }
    }
    
    func configureText(for cell: UITableViewCell, with name: String) {
      let label = cell.viewWithTag(1000) as! UILabel
      label.text = name
    }
}
