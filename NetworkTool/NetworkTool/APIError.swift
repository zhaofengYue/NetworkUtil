//
//  APIError.swift
//  NetworkTool
//
//  Created by OrderPlus on 2018/8/31.
//  Copyright © 2018年 zhaofengYue. All rights reserved.
//

import Foundation

enum APIError: Error {
    /// 普通的错误信息
    case error(errorMessage: String)
    /// 数据不是json格式
    case dataJSON(errorMessage: String)
    /// 数据不匹配
    case dataMatch(errorMessage: String)
    /// 数据为空
    case dataEmpty(errorMessage: String)
    /// 网络错误
    case netError(errorMessage: String)
    /// 网络错误的信息打印
    ///
    /// - Parameter error: 错误信息
    /// - Returns: 网络错误处理
    static func apiError(with error: NSError) -> APIError {
        print("This error message is \(error)")
        if error.domain == "Alamofire.AFError" {
            //处理自带的错误
            if error.code == 4 {
                return APIError.dataEmpty(errorMessage: "数据为空")
            }
        }
        return APIError.netError(errorMessage: "未知网络错误")
    }
}
