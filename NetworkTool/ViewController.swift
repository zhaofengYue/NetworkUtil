//
//  ViewController.swift
//  NetworkTool
//
//  Created by OrderPlus on 2018/7/16.
//  Copyright © 2018年 zhaofengYue. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var clickBtn: UIButton!
    @IBOutlet weak var cityNameLb: UILabel!
    
    var dataModel = DataModel()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    @IBAction func buttonClick(_ sender: UIButton) {
        dataModel.fetchSkyData().subscribe(onNext: { [weak self] model in
            self?.cityNameLb.text = model.skinfo!.cityName!
            print(APIUtil.httpsHeaders)
        }, onError: { (error) in
            print(error)
            print(APIUtil.httpsHeaders)
        }).disposed(by: disposeBag)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

