//
//  StoreAPI.swift
//  KCS
//
//  Created by 조성민 on 1/11/24.
//

import RxSwift
import Alamofire

enum APIType {
    
    case getStores
    case getImage
    case getSearchStores
    case getAutoCompletion
    case postNewStoreRequest
    case storeUpdateRequest
    
}

final class StoreAPI<T>: Router, URLRequestConvertible {
    
    typealias RequestValue = T
    
    let type: APIType
    
    init(type: APIType) {
        self.type = type
    }
    
    func execute(requestValue: T) -> URLRequest? {
        do {
            switch type {
            case .getStores:
                baseURL = getURL(type: .develop)
                parameters = try (requestValue as? RequestLocationDTO).asDictionary()
            case .getImage:
                baseURL = requestValue as? String
                parameters = [:]
            case .getSearchStores:
                baseURL = getURL(type: .develop)
                parameters = try (requestValue as? SearchDTO).asDictionary()
            case .getAutoCompletion:
                baseURL = getURL(type: .develop)
                parameters = try (requestValue as? AutoCompletionDTO).asDictionary()
            case .postNewStoreRequest:
                baseURL = getURL(type: .develop)
                parameters = try (requestValue as? NewStoreRequestDTO).asDictionary()
            case .storeUpdateRequest:
                baseURL = getURL(type: .develop)
                parameters = try (requestValue as? UpdateRequestDTO).asDictionary()
            }
            return try asURLRequest()
        } catch {
            return nil
        }
    }
    
    var baseURL: String?
    
    var path: String {
        switch type {
        case .getStores:
            return "/storecertification/byLocation/v2"
        case .getImage:
            return ""
        case .getSearchStores:
            return "/storecertification/byLocationAndKeyword/v1"
        case .getAutoCompletion:
            return "/store/autocorrect/v1"
        case .postNewStoreRequest:
            return "/report/newStore/v1"
        case .storeUpdateRequest:
            return "/report/specificStore/v1"
        }
    }
    
    var method: HTTPMethod {
        switch type {
        case .getStores, .getImage, .getSearchStores, .getAutoCompletion:
            return .get
        case .postNewStoreRequest, .storeUpdateRequest:
            return .post
        }
    }
    
    var headers: [String: String] {
        switch type {
        case .getStores, .getSearchStores, .getAutoCompletion, .postNewStoreRequest, .storeUpdateRequest:
            return [
                "Content-Type": "application/json"
            ]
        case .getImage:
            return [:]
        }
    }
    
    var parameters: [String: Any]?
    
    /// 파라미터로 보내야할 것이 있다면, URLEncoding.default
    /// 바디에 담아서 보내야할 것이 있다면, JSONEncoding.default
    var encoding: ParameterEncoding? {
        switch type {
        case .getStores, .getSearchStores, .getAutoCompletion:
            return URLEncoding.default
        case .postNewStoreRequest, .storeUpdateRequest:
            return JSONEncoding.default
        case .getImage:
            return nil
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let base = baseURL,
              let url = URL(string: base + path) else {
            throw NetworkError.wrongURL
        }
        var request = URLRequest(url: url)
        
        request.method = method
        request.headers = HTTPHeaders(headers)
        
        if let encoding = encoding {
            if let parameters = parameters {
                return try encoding.encode(request, with: parameters)
            } else {
                throw NetworkError.wrongParameters
            }
        }
        
        return request
    }
    
}

private extension StoreAPI {
    
    enum URLType {
        
        case develop
        case product
        
    }
    
    func getURL(type: URLType) -> String? {
        switch type {
        case .develop:
            guard let url = Bundle.main.object(forInfoDictionaryKey: "DEV_SERVER_URL") as? String else { return nil }
            return url
        case .product:
            guard let url = Bundle.main.object(forInfoDictionaryKey: "PROD_SERVER_URL") as? String else { return nil }
            return url
        }
    }
    
}
