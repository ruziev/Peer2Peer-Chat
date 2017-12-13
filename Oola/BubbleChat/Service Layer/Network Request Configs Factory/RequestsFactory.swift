
import Foundation

struct RequestsFactory {
    struct PixabayRequests {
        static func imageInfosConfig(keywords: [String], page: Int = 1) -> RequestConfigMany<PixabayImageInfoModel, PixabayImageInfoParser> {
            return RequestConfigMany(
                request: PixabayImageInfoRequest(apiKey: "7095009-d65414cc94cbb0b1bf16186d2", keywords: keywords, page: page),
                parser: PixabayImageInfoParser()
            )
        }
        
        static func imagesConfig(url: URL) -> RequestConfig<PixabayImageModel, PixabayImageParser> {
            return RequestConfig(
                request: PixabayImageRequest(url: url),
                parser: PixabayImageParser()
            )
        }
    }
}
