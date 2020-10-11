//
//  APIUtil.swift
//  NetworkTool
//
//  Created by OrderPlus on 2018/8/31.
//  Copyright © 2018年 zhaofengYue. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON
import RxSwift

struct APIUtil {
    static var httpsHeaders: HTTPHeaders = ["Content-Type": "application/json"]
}

extension APIUtil {
    /// 获取数据
    ///
    /// - Parameters:
    ///   - url: 路由地址
    ///   - method: 请求方式
    ///   - parameters: 参数
    ///   - returnType: 返回类型
    /// - Returns: 返回一个Rx序列
    static func fetchData<T: HandyJSON>(with url: Router, method: HTTPMethod = .post, parameters: Parameters?, returnType: T.Type) -> Observable<T> {
        return Observable<T>.create({ (observer: AnyObserver<T>) -> Disposable in
            self.request(observer: observer, url: url, method: method, parameters: parameters, returnType: returnType)
            return Disposables.create()
        })
    }
    
    /// 上传数据
    ///
    /// - Parameters:
    ///   - url: 路由地址
    ///   - method: 请求方式
    ///   - uploadDatas: 上传数据的数组
    ///   - parameters: 参数(可以不填)
    ///   - returnType: 返回类型
    /// - Returns: 返回一个Rx序列
    static func uploadData<T: HandyJSON>(with url: Router, method: HTTPMethod, uploadDatas: [UploadData]?, parameters: Parameters? = nil, returnType: T.Type) -> Observable<T> {
        return Observable<T>.create({ (observer: AnyObserver<T>) -> Disposable in
            self.uploadRequest(observer: observer, url: url, method: method, uploadDatas: uploadDatas, parameters: parameters, returnType: returnType)
            return Disposables.create()
        })
    }
}

extension APIUtil {
    /// 网络请求成功之后的回调
    ///
    /// - Parameters:
    ///   - observer: Rx 的观察者(传递数据)
    ///   - result: 请求结果
    ///   - retrunType: 返回值类型
    fileprivate static func successHandle<T: HandyJSON>(observer: AnyObserver<T>, result: Result<Any>, retrunType: T.Type) {
        // 如果解析出来的不是json
        guard let JSON = result.value, let jsonDic = JSON as? [String: Any] else {
            failHandle(observer: observer, error: APIError.dataJSON(errorMessage: "非JSON格式的数据"))
            return
        }
        // jsonDic是原始数据，将其转成HandyJSON
        guard let responseModel = retrunType.deserialize(from: NSDictionary(dictionary: jsonDic)) else {
            failHandle(observer: observer, error: APIError.dataMatch(errorMessage: "无法解析"))
            return
        }
        observer.onNext(responseModel)
        observer.onCompleted()
    }
    
    /// 网络请求失败的回调
    ///
    /// - Parameters:
    ///   - observer: Rx 的观察者
    ///   - error: 错误信息
    fileprivate static func failHandle<T: HandyJSON>(observer: AnyObserver<T>, error: Error) {
        observer.onError(APIError.apiError(with: error as NSError))
        observer.onCompleted()
    }
}

extension APIUtil {
    /// 网络请求方法
    ///
    /// - Parameters:
    ///   - observer: Rx 观察者
    ///   - url: 路由地址
    ///   - method: 请求方式
    ///   - parameters: 参数
    ///   - returnType: 返回类型
    fileprivate static func request<T: HandyJSON>(observer: AnyObserver<T>, url: Router, method: HTTPMethod, parameters: Parameters?, returnType: T.Type) {
        Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: self.httpsHeaders).responseJSON { (response) in
            switch response.result {
            case .success:
                self.successHandle(observer: observer, result: response.result, retrunType: returnType)
                break
            case .failure(let error):
                self.failHandle(observer: observer, error: APIError.apiError(with: error as NSError))
                break
            }
        }
    }
    
    /// 上传方法
    ///
    /// - Parameters:
    ///   - observer: Rx 观察者
    ///   - url: 路由地址
    ///   - method: 请求方式
    ///   - uploadDatas: 上传的数据数组
    ///   - parameters: 参数
    ///   - returnType: 返回类型
    fileprivate static func uploadRequest<T: HandyJSON>(observer: AnyObserver<T>, url: Router, method: HTTPMethod, uploadDatas: [UploadData]?, parameters: Parameters?, returnType: T.Type) {
        Alamofire.upload(multipartFormData: { data in
            // Parameters
            if let parameters = parameters {
                for param in parameters {
                    let value = (param.value as! String).data(using: .utf8)
                    data.append(value!, withName: param.key)
                }
            }
            // uploadData
            if let toUploadDatas = uploadDatas {
                for toUploadData in toUploadDatas {
                    if let uploadData = toUploadData.data {
                        data.append(uploadData, withName: toUploadData.name!, fileName: toUploadData.fileName!, mimeType: toUploadData.mimeType!)
                    }
                }
            }
        }, to: url, method: method, headers: httpsHeaders) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response: DataResponse<Any>) in
                    successHandle(observer: observer, result: response.result, retrunType: returnType)
                })
            case .failure(let encodingError):
                failHandle(observer: observer, error: encodingError)
            }
        }
    }
}

/// 上传数据的模型
struct UploadData {
    //可以自定义
    var name: String? = "name"
    var fileName: String? = "fileName"
    var mimeType: String? = "type"
    var data: Data?
    
    init(name: String? = nil, filename: String? = nil, mimeType: String? = nil, data: Data? = nil) {
        
        if let name = name {
            self.name = name
        }
        
        if let fileName = fileName {
            self.fileName = fileName
        }
        
        if let mimeType = mimeType {
            self.mimeType = mimeType
        }
        
        if let data = data {
            self.data = data
        }
    }
}

extension APIUtil {
    /// 摒弃Rx的请求数据方法
    static func requestData<T: HandyJSON>(with url: Router, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.queryString, returnType: T.Type, success: @escaping ((_ model: T) -> Void), fail: @escaping ((_ error: Error) -> Void)) {
        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: httpsHeaders).responseJSON { (response) in
            switch response.result {
            case .success:
                // 如果解析出来的不是json
                guard let JSON = response.result.value, let jsonDic = JSON as? [String: Any] else { return }
                // jsonDic是原始数据，将其转成HandyJSON
                guard let responseModel = returnType.deserialize(from: NSDictionary(dictionary: jsonDic)) else { return }
                success(responseModel)
            case .failure(let error):
                fail(error)
            }
        }
    }
}
