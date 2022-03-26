//
//  NoInternetVC.swift
//  Mangal house
//
//  Created by Kinjal Sojitra on 22/04/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class NoInternetVC: Main {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }

    @IBAction func btnBack_Action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
