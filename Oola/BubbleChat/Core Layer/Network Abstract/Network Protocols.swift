
import Foundation

protocol IRequest {
    var urlRequest: URLRequest? {get set}
}

protocol IParser {
    associatedtype ModelType
    func parse(from data: Data) -> ModelType?
}

struct RequestConfig<ModelType, Parser: IParser> where Parser.ModelType == ModelType {
    let request: IRequest
    let parser: Parser
}

struct RequestConfigMany<ModelType, Parser: IParser> where Parser.ModelType == [ModelType] {
    let request: IRequest
    let parser: Parser
}

protocol IRequestSender {
    func send<ModelType, Parser>(config: RequestConfig<ModelType, Parser>, completionHandler: @escaping (Result<ModelType>) -> Void )
    func send<ModelType, Parser>(config: RequestConfigMany<ModelType, Parser>, completionHandler: @escaping (Result<[ModelType]>) -> Void )
}

enum Result<ModelType> {
    case success(ModelType)
    case error(String)
}
