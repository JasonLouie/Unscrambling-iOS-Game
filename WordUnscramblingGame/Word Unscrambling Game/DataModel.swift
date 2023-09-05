//
//  DataModel.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 5/4/22.
//

import Foundation

class DataModel {
    var gameData = GameData()
    var shouldResetData: Bool {
        get{
            return UserDefaults.standard.bool(forKey: "ResetData")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "ResetData")
        }
    }
    
    var randomBounds: Bool {
        get{
            return UserDefaults.standard.bool(forKey: "RandomBounds")
        }
        set{
            return UserDefaults.standard.set(newValue, forKey: "RandomBounds")
        }
    }
    
    var showKeyBoard: Bool {
        get{
            return UserDefaults.standard.bool(forKey: "KeyboardShown")
        }
        set{
            return UserDefaults.standard.set(newValue,forKey: "KeyboardShown")
        }
    }
    
    var optionsResetRound: Bool {
        get{
            return UserDefaults.standard.bool(forKey: "ResetRound")
        }
        set{
            return UserDefaults.standard.set(newValue, forKey: "ResetRound")
        }
    }
    
    init(){
        loadGame()
        registerDefaults()
        handleFirstTime()
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("WordUnscramblingGame.plist")
    }
    
    func saveGame(){
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(gameData)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch{
            print("Error encoding text: \(error.localizedDescription)")
        }
    }
    
    func loadGame(){
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path){
            let decoder = PropertyListDecoder()
            do{
                gameData = try decoder.decode(GameData.self, from: data)
            } catch {
                print("Error decoding game data: \(error.localizedDescription)")
            }
        }
    }
    
    func registerDefaults(){
        let dictionary = [ "ResetData": false, "RandomBounds": false, "KeyboardShown": false, "ResetRound": false, "FirstTime": true ] as [String: Any]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            shouldResetData = true
            userDefaults.set(false, forKey: "FirstTime")
            gameData.userFirstTime()
        }
    }
}
