//
//  Router.swift
//  NetworkTool
//
//  Created by OrderPlus on 2018/7/17.
//  Copyright © 2018年 zhaofengYue. All rights reserved.
//

import UIKit
import Alamofire

enum Router: String, URLConvertible {
    
    case tianqi = "data/sk/101010100.html"
    
    /// 实现协议方法
    func asURL() throws -> URL {
        return URL(string: urlString())!
    }
    
    /// 拼接过的地址链接
    var urlString: String {
        return Router.baseUrl.appending(rawValue)
    }
    
    /// 主机地址
    static var baseUrl: String  = "http://mobile.weather.com.cn/"
    
    /// 请求方法
    static var httpMethod: HTTPMethod = .post
}
