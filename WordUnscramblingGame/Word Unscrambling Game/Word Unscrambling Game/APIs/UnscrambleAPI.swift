//
//  UnscrambleAPI.swift
//  Word Unscrambling Game
//
//  Created by Jason Louie on 4/27/22.
//

import Foundation

class UnscrambleAPI{
    static let UnscrambleAPIInstance = UnscrambleAPI()
    private init(){
    }
    var dataTask: URLSessionDataTask?
    var possibleWords = [WordResult]()
    
    let headers = [
        "x-rapidapi-host": "danielthepope-countdown-v1.p.rapidapi.com",
        "x-rapidapi-key": "296ba25fd1msh7b608803a053ff4p1371bdjsn0b132405d653"
    ]

    func parse(data: Data) -> [WordResult]{
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode([WordResult].self, from: data)
            return result
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }

    func unscrambleWord(_ word: String, completion: @escaping ([WordResult]?) -> Void){
        dataTask?.cancel()
        let url = APIURL(unscrambleWord: word)
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        dataTask = session.dataTask(with: request as URLRequest) {data, response, error in
            if let error = error as NSError?, error.code == -999{
                completion(nil)
                return // Search was cancelled
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200{
                if let data = data{
                    let results = self.parse(data: data)
                    self.possibleWords = results
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

    func APIURL(unscrambleWord: String) -> URL {
        let encodedText = unscrambleWord.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://danielthepope-countdown-v1.p.rapidapi.com/solve/%@?variance=-1",encodedText)
        let url = URL(string: urlString)
        return url!
    }
}
