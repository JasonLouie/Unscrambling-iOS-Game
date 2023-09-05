//
//  RandomWordAPI.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/27/22.
//

import Foundation

class RandomWordAPI{
    static let RandomWordAPIInstance = RandomWordAPI()
    private init(){
    }
    
    var word = ""
    var dataTask: URLSessionDataTask?
    
    let headers = [
        "X-RapidAPI-Host": "random-words5.p.rapidapi.com",
        "X-RapidAPI-Key": "9dcabfb453msh07c73ebd795a4bap1e1175jsn39e71811e6af"
    ]
    
    func generateWord(_ length: Int, _ randomize: Bool, completion: @escaping (String?) -> Void){
        dataTask?.cancel()
        var urlString = "https://random-words5.p.rapidapi.com/getRandom?wordLength=\(length)"
        if randomize{
            urlString = "https://random-words5.p.rapidapi.com/getRandom?minLength=5&maxLength=12"
        }
        let url = URL(string: urlString)
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        dataTask = session.dataTask(with: request as URLRequest) {data, response, error in
            if let error = error as NSError?, error.code == -999{
                completion(nil)
                return // Search was cancelled
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200{
                if data != nil{
                    let result = String(data: data!, encoding: .utf8)!
                    self.word = result
                    self.scrambleWord()
                    completion(result)
                    return
                }
            } else{
                print("Failure! \(response!)")
                completion(nil)
            }
        }
        dataTask?.resume()
    }
    
    func scrambleWord(){
        var wordArray = [String]()
        var newWord = ""
        for ch in word{
            wordArray.append(String(ch))
        }
        wordArray.shuffle()
        
        for ch in wordArray{
            newWord+=ch
        }
        if word == newWord{
            scrambleWord()
        }
        word = newWord
    }
}
