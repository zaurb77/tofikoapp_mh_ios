//
//  AppUpdatePopupVC.swift
//  Mangal house
//
//  Created by Kinjal Sojitra on 22/04/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class AppUpdatePopupVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnUpdate: CustomButton!
    
    //MARK: Instantiate Methods
    static func instantiate() -> AppUpdatePopupVC? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(AppUpdatePopupVC.self)") as? AppUpdatePopupVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = Language.UPGRADE_APP
        lblDesc.text = Language.UPGRADE_MESSAGE
        btnUpdate.setTitle(Language.UPDATE, for: .normal)
    }
    
    //MARK:- Button Actions
    @IBAction func btnUpdate_Action(_ sender: Any) {
        guard let url = URL(string: Constant.APP_STORE_LINK) else {
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
