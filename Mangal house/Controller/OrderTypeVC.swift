//
//  OrderTypeVC.swift
//  Mangal house
//
//  Created by Mahajan on 22/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit

class OrderTypeVC: Main {  
    
    //MARK:- Outlets
    @IBOutlet weak var vwTruck: UIView!
    @IBOutlet weak var vwHome: UIView!
    
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDelivery: UILabel!
    @IBOutlet weak var lblTakeaway: UILabel!
    
    
    //MARK:- Global Variables
    var comeFrom = ""
    var itemId = ""
    var resId = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        vwTruck.layer.cornerRadius = 10
        vwTruck.layer.shadowColor = UIColor.lightGray.cgColor
        vwTruck.layer.shadowOffset = CGSize(width: -1, height: 1)
        vwTruck.layer.shadowOpacity = 0.7
        vwTruck.layer.shadowRadius = 4.0
        
        vwHome.layer.cornerRadius = 10
        vwHome.layer.shadowColor = UIColor.lightGray.cgColor
        vwHome.layer.shadowOffset = CGSize(width: -1, height: 1)
        vwHome.layer.shadowOpacity = 0.7
        vwHome.layer.shadowRadius = 4.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        
        lblDesc.text = "\(Language.HOW_WOULD_LIKE)\n\(Language.RECEIVE_ORDER)"
        lblDelivery.text = Language.DELIVERY
        lblTakeaway.text = Language.TAKEAWAY_FROM_STORE
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDelivery_Action(_ sender: Any) {
        
        if isGuestUser() {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "StoreListVC") as! StoreListVC
            vc.addressID = ""
            vc.orderType = "pickup"
            vc.subErrorText = ""
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else {
            if comeFrom == "BANNER_ITEM" || comeFrom == "BANNER_ITEM_COMBO"{
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressListVC") as! AddressListVC
                vc.comeFrom = self.comeFrom
                vc.orderType = "delivery"
                vc.itemId = self.itemId
                vc.resId = self.resId
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressListVC") as! AddressListVC
                vc.orderType = "delivery"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func btnHome_Action(_ sender: Any) {
        
        if comeFrom == "BANNER_ITEM" {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailVC") as! ItemDetailVC
            vc.comeFrom = self.comeFrom
            vc.orderType = "pickup"
            vc.itemId = self.itemId
            vc.resId = self.resId
            self.navigationController?.pushViewController(vc, animated: true)
                        
        } else if comeFrom == "BANNER_ITEM_COMBO" {
            callAddToCartAPI()
        
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantMapViewVC") as! RestaurantMapViewVC
            vc.orderType = "pickup"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    //MARK:- Web Service Calling
    func callAddToCartAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        var cartId = ""
        if self.settingModel.cart_id != nil {
            cartId = self.settingModel.cart_id
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ADD_TO_CART
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&restaurant_id=\(self.resId)&item_id=\(self.itemId)&quantity=1&paid_customization=&free_customization=&cart_id=\(cartId)&address_id=&order_type=pickup"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            if let isDiffRes = responseData["isdiff_res"] as? String, isDiffRes == "1" {
                                
                                var old = ""
                                if let oldName = responseData["diff_res_name"] as? String {
                                    old = oldName
                                }
                                self.showAlertView(Language.REPLACE_CART_ITEM, "\(Language.CART_CONTAINS_FROM) \(old). \(Language.DISCARD_SELECTION)", defaultTitle: Language.YES_LABEL, cancelTitle: Language.NO_LABEL) { (finish) in
                                    if finish {
                                        self.settingModel.cart_id = ""
                                        self.callAddToCartAPI()
                                    }
                                }
                                
                            }else {
                                if let cart_id = responseData["cart_id"] as? String  {
                                    self.settingModel.cart_id = cart_id
                                }
                                self.showSuccess(jsonObject["message"] as! String)
                                
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
                                vc.isFrom = "address"
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            
                        } else {
                            self.showError(Language.WENT_WRONG)
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}
