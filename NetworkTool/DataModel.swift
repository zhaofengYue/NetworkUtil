//
//  DataModel.swift
//  NetworkTool
//
//  Created by OrderPlus on 2018/7/25.
//  Copyright © 2018年 zhaofengYue. All rights reserved.
//

import Foundation
import HandyJSON
import RxSwift

struct DataModel: HandyJSON {
    var skinfo: SkyInfo?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.skinfo <-- "sk_info"
    }
}

struct SkyInfo: HandyJSON {
    var areaID: Int = 0
    var cityName: String?
    var date: String?
    var sd: String?
    var sm: String?
    var temp: String?
    var tempF: String?
    var time: String?
    var wd: String?
    var ws: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &date) { (dateInt) -> String in
            return "\(dateInt)"
        }
    }
}

extension DataModel {
    func fetchSkyData() -> Observable<DataModel> {
        return APIUtil.fetchData(with: .tianqi, method: .get, parameters: ["_" : "1381891661455"], returnType: DataModel.self).map({ (response: DataModel) -> DataModel in
            return response
        })
    }
}
