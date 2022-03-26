//
//  OrderAckVC.swift
//  Mangal house
//
//  Created by Mahajan on 01/01/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class OrderAckVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var lblOrderSuccess: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnContinueShopping: CustomButton!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblOrderSuccess.text = Language.ORDER_SUCCESS
        lblMessage.text = Language.ORDER_SUCCESS_DESC
        btnContinueShopping.setTitle(Language.CONTINUE_SHOPPING, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        
        self.settingModel.cart_id = ""
        self.settingModel.selected_delivery_address = ""
        self.settingModel.orderType = ""
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
    }
    
   
    @IBAction func btnContinue_Action(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
    }
}
