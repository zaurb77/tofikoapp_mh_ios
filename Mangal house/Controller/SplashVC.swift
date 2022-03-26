//
//  SplashVC.swift
//  Mangal house
//
//  Created by Kinjal Sojitra on 07/04/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class SplashVC: Main {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3.0) {
            
            if UserModel.sharedInstance().user_id != nil && UserModel.sharedInstance().user_id! != "" {
                (UIApplication.shared.delegate as! AppDelegate).resetPushCounter()
                (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
                
            }else if UserModel.sharedInstance().isGuestLogin != nil && UserModel.sharedInstance().isGuestLogin! != ""  && UserModel.sharedInstance().isGuestLogin! == "1"{
                (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
                
            }else {
                (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Login()
            }
        }
    }
    
    
}
