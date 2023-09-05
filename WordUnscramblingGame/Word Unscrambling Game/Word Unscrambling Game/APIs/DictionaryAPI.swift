//
//  DictionaryAPI.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/25/22.
//

import Foundation

class DictionaryAPI{
    static let DictionaryAPIInstance = DictionaryAPI()
    private init(){
    }
    var dataTask: URLSessionDataTask?
    var dataOfWord = [DictionaryResultInnerArray]()
    
    let headers = ["content-type": "application/json","X-RapidAPI-Host": "xf-english-dictionary1.p.rapidapi.com","X-RapidAPI-Key": "9dcabfb453msh07c73ebd795a4bap1e1175jsn39e71811e6af"]
    
    func parse(data: Data) -> [DictionaryResultInnerArray] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(DictionaryResultOuterArray.self, from: data)
            return result.items
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    // Citation for using completion parameter: 
    func infoOfWord(_ word: String, completion: @escaping ([DictionaryResultInnerArray]?) -> Void){
        dataTask?.cancel()
        let url = APIURL(infoOfWord: word)
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        dataTask = session.dataTask(with: request as URLRequest) {data, response, error in
            if let error = error as NSError?, error.code == -999{
                completion(nil)
                return // Search was cancelled
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200{
                if let data = data{
                    let results = self.parse(data: data)
                    self.dataOfWord = results
                    completion(results)
                    return
                }
            } else{
                print("Failure! \(response!)")
                completion(nil)
            }
        }
        dataTask?.resume()
    }
    
    func APIURL(infoOfWord: String) -> URL {
        let encodedText = infoOfWord.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://xf-english-dictionary1.p.rapidapi.com/v1/dictionary?selection=%@&synonyms=true&audioFileLinks=false&pronunciations=false&relatedWords=false&antonyms=false",encodedText)
        let url = URL(string: urlString)
        return url!
    }
}



