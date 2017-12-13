

import Foundation
import SwiftyJSON

class PixabayImageInfoRequest : IRequest {
    var urlRequest: URLRequest?
    
    init(apiKey: String, keywords: [String], page: Int = 1) {
        let whitespaces = NSCharacterSet.whitespaces
        
        for keyword in keywords {
            guard keyword.rangeOfCharacter(from: whitespaces) == nil else {
                print("Keywords should not contain whitespace symbols")
                assert(false)
            }
        }
        
        let keywordsJoined = keywords.joined(separator: "+")
        
        guard let url = URL(string: "https://pixabay.com/api/?key=\(apiKey)&q=\(keywordsJoined)&image_type=photo&page=\(page)") else {
            print("Could not create URL")
            return
        }
        urlRequest = URLRequest(url: url)
    }
}

struct PixabayImageInfoModel {
    let imageUrl: URL
}

class PixabayImageInfoParser: IParser {
    
    typealias ModelType = [PixabayImageInfoModel]
    
    func parse(from data: Data) -> [PixabayImageInfoModel]? {
        let json = JSON(data: data)
        
        var models: [PixabayImageInfoModel] = []
        
        guard let items = json["hits"].array else {
            return []
        }
        
        for item in items {
            if let imageUrl = item["webformatURL"].url {
                models.append(PixabayImageInfoModel(imageUrl: imageUrl))
            }
        }
        
        return models
    }
}
