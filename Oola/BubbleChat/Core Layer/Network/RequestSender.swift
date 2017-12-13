
import Foundation

class RequestSender: IRequestSender {
    init(async: Bool = false, qos: DispatchQoS.QoSClass? = nil) {
        if async {
            self.async = async
            self.qos = qos ?? .userInitiated
        }
    }
    
    let session = URLSession.shared
    var qos: DispatchQoS.QoSClass? = nil
    var async: Bool = false
    
    func send<ModelType, Parser>(config: RequestConfig<ModelType, Parser>, completionHandler: @escaping (Result<ModelType>) -> Void) {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.error("URL string can not be parsed to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.error(error.localizedDescription))
                return
            }
            guard let data = data, let parsedModel = config.parser.parse(from: data) else {
                completionHandler(Result.error("Received data can not be parsed"))
                return
            }
            
            completionHandler(Result.success(parsedModel))
        }
        
        if async {
            guard let qos = self.qos else {
                print("QoS is required in async Request Sender")
                return
            }
            DispatchQueue.global(qos: qos).async {
                task.resume()
            }
        }
        else {
            task.resume()
        }
    }
}

// MARK: - RequestConfigMany
extension RequestSender {
    func send<ModelType, Parser>(config: RequestConfigMany<ModelType, Parser>, completionHandler: @escaping (Result<[ModelType]>) -> Void) {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.error("URL string can not be parsed to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.error(error.localizedDescription))
                return
            }
            guard let data = data, let parsedModel = config.parser.parse(from: data) else {
                completionHandler(Result.error("Received data can not be parsed"))
                return
            }
            
            completionHandler(Result.success(parsedModel))
        }
        
        if async {
            guard let qos = self.qos else {
                print("QoS is required in async Request Sender")
                return
            }
            DispatchQueue.global(qos: qos).async {
                task.resume()
            }
        }
        else {
            task.resume()
        }
    }
}
