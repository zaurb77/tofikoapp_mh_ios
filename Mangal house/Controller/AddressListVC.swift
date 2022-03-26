//
//  AddressListVC.swift
//  Mangal house
//
//  Created by Mahajan on 24/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit

class AddressListCell : UITableViewCell{
    
    @IBOutlet weak var lblAddressType: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var ivSelect: CustomImageView!
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
}

class AddressListVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var tblAddress: UITableView!
    @IBOutlet weak var lblHeadingMessage: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var cnsHeightBtnContinue: NSLayoutConstraint!
    
    //MARK:- Global Variables
    var comeFrom = ""
    var itemId = ""
    var resId = ""
    var orderType = ""
    var selectedAddressId = ""
    var arrDictData = [[String:AnyObject]]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = Language.ADDRESS.uppercased()
        lblHeadingMessage.text = Language.DELIVERY_ADDRESS
        
        btnAdd.layer.cornerRadius = btnAdd.frame.size.height / 2
        btnAdd.layer.shadowColor = UIColor.lightGray.cgColor
        btnAdd.layer.shadowOffset = CGSize(width: -2, height: 2)
        btnAdd.layer.shadowOpacity = 0.7
        btnAdd.layer.shadowRadius = 10.0
        
        if comeFrom == "CHANGE_ADDRESS" {
            btnContinue.setTitle(Language.SAVE.uppercased(), for: .normal)
        }else {
            btnContinue.setTitle(Language.CONTINUE.uppercased(), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        callAddressListAPI()
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAdd_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toAdd", sender: nil)
    }
    
    @IBAction func btnContinue_Action(_ sender: Any) {
        
        if selectedAddressId == "" {
            self.showWarning(Language.DELIVERY_ADDRESS)
            
        } else {
            if comeFrom == "BANNER_ITEM" {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailVC") as! ItemDetailVC
                vc.selectedAddressId = self.selectedAddressId
                vc.orderType = self.orderType
                vc.itemId = self.itemId
                vc.resId = self.resId
                vc.comeFrom = self.comeFrom
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if comeFrom == "BANNER_ITEM_COMBO" {
                callAddToCartAPI()
                
            }else {
                
                if self.comeFrom == "CHANGE_ADDRESS" {
                    callGetNearestRestAPI()
                }else {
                    ///if restaurant counter is 1 then directly pass to order screen
                    callRestaurantListAPI()
                }
                
            }
        }
    }
    
    
    //MARK:- Other Functions
    
   
    
    
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
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&restaurant_id=\(self.resId)&item_id=\(self.itemId)&quantity=1&paid_customization=&free_customization=&cart_id=\(cartId)&address_id=\(self.selectedAddressId)&order_type=\(self.orderType)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
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
    
    func callGetNearestRestAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: Date())
        
        df.dateFormat = "EEEE"
        let dayName = df.string(from: Date())
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_NEAREST_RESTAURANT
        let params = "?address_id=\(self.selectedAddressId)&time=\(time)&day=\(dayName.lowercased())&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        
                        //Getting data from API.
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            if self.selectedAddressId == "" {
                                self.showError(Language.DELIVERY_ADDRESS)
                                
                            }else {
                                
                                if let res_id = responseData["res_id"] as? String  {
                                    self.settingModel.near_res_id = res_id
                                }
                                
                                self.settingModel.orderType = "delivery"
                                self.navigationController?.popViewController(animated: true)
                            }
                            
//                            if let res_id = responseData["res_id"] as? String  {
//                                self.settingModel.near_res_id = res_id
//                            }
//
//                            if self.comeFrom == "CHANGE_ADDRESS" {
//                                if self.selectedAddressId == "" {
//                                    self.showWarning("Error", "Please select a delivery address.")
//
//                                }else {
//                                    self.settingModel.orderType = "delivery"
//                                    self.navigationController?.popViewController(animated: true)
//                                }
//                            }else {
//                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderMenuVC") as! OrderMenuVC
//                                vc.selectedAddressId = self.selectedAddressId
//                                vc.orderType = self.orderType
//                                vc.resId = self.settingModel.near_res_id
//                                self.navigationController?.pushViewController(vc, animated: true)
//                            }
                            
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
    
    func callRestaurantListAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: Date())
        
        df.dateFormat = "EEEE"
        let dayName = df.string(from: Date())
        
        let lat = String(format: "%.5f", LocationManager.sharedInstance.latitude)
        let lng = String(format: "%.5f", LocationManager.sharedInstance.longitude)
        
        var oType = ""
        if orderType == "" {
            oType = "pickup"
        }else {
            oType = orderType
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_RESTAURANT_LIST
        let params = "?latitude=\(lat)&longitude=\(lng)&time=\(time)&day=\(dayName)&address_id=\(selectedAddressId)&order_type=\(oType)&company_id=\(company_id)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StoreListVC") as! StoreListVC
                        vc.addressID = self.selectedAddressId
                        vc.subErrorText = jsonObject["message"] as! String
                        vc.orderType = self.orderType
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]], responseData.count > 0 {
                         
                            if responseData.count == 1{
                                let data = responseData[0]
                                if let res_id = data["id"] as? String  {
                                    self.settingModel.near_res_id = res_id
                                }
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderMenuVC") as! OrderMenuVC
                                vc.selectedAddressId = self.selectedAddressId
                                vc.orderType = self.orderType
                                vc.resId = self.settingModel.near_res_id
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else{
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "StoreListVC") as! StoreListVC
                                vc.addressID = self.selectedAddressId
                                vc.orderType = self.orderType
                                vc.subErrorText = jsonObject["message"] as! String
                                vc.arrStoreData = responseData
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callAddressListAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_ADDRESS_LIST
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
//                        self.showWarning(jsonObject["message"] as! String)
                        
                        self.arrDictData.removeAll()
                        self.lblHeadingMessage.isHidden = true
                        self.lblTitle.isHidden = true
                        self.cnsHeightBtnContinue.constant = 0
                        self.tblAddress.reloadData()
                        
                    }else{
                        print(jsonObject)
                        
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]], responseData.count > 0 {
                            
                            self.arrDictData = responseData
                            self.lblHeadingMessage.isHidden = false
                            self.lblTitle.isHidden = false
                            self.cnsHeightBtnContinue.constant = 50
                            
                        } else {
                            self.lblHeadingMessage.isHidden = true
                            self.lblTitle.isHidden = true
                            self.cnsHeightBtnContinue.constant = 0
                            self.showError(Language.WENT_WRONG)
                        }
                        self.tblAddress.reloadData()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callDeleteAddressAPI(_ addressID: String) {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ADDRESS
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&address_id=\(addressID)&type=delete"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        self.callAddressListAPI()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callSetGetDeliveryAddressAPI() {
        
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
        let serviceURL = Constant.WEBURL + Constant.API.SET_GET_DELIVERY_ADDRESS
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&address_id=\(self.selectedAddressId)&cart_id=\(cartId)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            self.selectedAddressId = responseData["address_id"] as! String
                        }
                        
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

}
extension AddressListVC: UITableViewDelegate, UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if arrDictData.count > 0 {
            numOfSections            = 1
            tblAddress.backgroundView = nil
        }
        else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tblAddress.bounds.size.width, height: tblAddress.bounds.size.height))
            noDataLabel.text          = Language.ADDRESS_ERROR
            noDataLabel.textColor     = UIColor(red: 102/255, green: 100/255, blue: 100/255, alpha: 1.0)
            noDataLabel.font = UIFont(name: "Raleway-Regular", size: 18.0)
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            tblAddress.backgroundView  = noDataLabel
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDictData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressListCell") as! AddressListCell
        
        cell.lblAddressType.text = (arrDictData[indexPath.row]["address_type"] as! String).uppercased()
        cell.lblAddress.text = arrDictData[indexPath.row]["address_line"] as? String
        
        if selectedAddressId == arrDictData[indexPath.row]["address_id"] as! String {
            cell.ivSelect.image = UIImage(named: "checkmark")
        }else {
            cell.ivSelect.image = UIImage(named: "uncheckmark")
        }
        
        cell.btnEdit.tag = indexPath.row
        cell.btnEdit.addTarget(self, action: #selector(btnEdit_Action), for: .touchUpInside)
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(btnDelete_Action), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddressId = arrDictData[indexPath.row]["address_id"] as! String
        tblAddress.reloadData()
        
        if comeFrom == "CHANGE_ADDRESS" {
            callSetGetDeliveryAddressAPI()
        }
    }
    
    @objc func btnEdit_Action(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
        vc.dictAddress = arrDictData[sender.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnDelete_Action(_ sender: UIButton) {
        callDeleteAddressAPI(arrDictData[sender.tag]["address_id"] as! String)
    }
}
