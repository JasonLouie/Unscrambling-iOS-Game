//
//  GameData.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 5/6/22.
//

import Foundation

class GameData: NSObject, Codable{
    var score = 0
    var highscore = 0
    var scoreDifference = 0
    var wordBound = 5
    var minimumWordSize = 3
    var possibleWords = [WordResult]()
    var highscoreAltered = false
    var scrambledword = ""
    var foundList = [WordItem]()
    var missedList = [WordItem]()
    
    func restartRound(){
        foundList.removeAll()
        possibleWords.removeAll()
        missedList.removeAll()
        score = 0
        scoreDifference = 0
        highscoreAltered = false
    }
    
    func userFirstTime(){
        foundList.removeAll()
        possibleWords.removeAll()
        missedList.removeAll()
        score = 0
        scoreDifference = 0
        highscoreAltered = false
        scrambledword = ""
        highscore = 0
        wordBound = 5
        minimumWordSize = 3
    }
}
