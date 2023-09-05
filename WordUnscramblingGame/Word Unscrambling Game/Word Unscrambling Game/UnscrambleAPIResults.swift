//
//  UnscrambleAPIResults.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/29/22.
//

import Foundation

class WordResult : Codable, CustomStringConvertible {
    var word: String? = ""
    var description: String {
        return "\nResult - Word: \(word ?? "None")"
    }
}
