//
//  DictionaryAPIResult.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/24/22.
//

import Foundation

class DictionaryResultOuterArray: Codable {
    var items = [DictionaryResultInnerArray]()
}

class DictionaryResultInnerArray : Codable, CustomStringConvertible {
    var definitions = [DictionaryResult]()
    var partOfSpeech: String?
    var synonyms: [String]?
    
    var description: String{
        return "\nResult - Definitions: \(definitions), Part of Speech: \(partOfSpeech ?? "None"), Synonyms: \(String(describing: synonyms ?? ["No Synonyms"]))"
    }
}

class DictionaryResult: Codable, CustomStringConvertible {
    var definition: String?
    var examples: [String]?
    
    var description: String{
        return "\nDefinition: \(definition ?? "None"), Sentences: \(String(describing: examples ?? ["No Sentences"]))"
    }
}

class Sentences : Codable, CustomStringConvertible {
    var sentence: String?
    
    var description: String{
        return "\n Sentences: \(sentence ?? "No Sentence")"
    }
}


