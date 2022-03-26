//
//  OrderHistoryDetailVC.swift
//  Mangal house
//
//  Created by Mahajan on 09/01/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import SDWebImage

class OrderHistoryItemCell : UITableViewCell{
    
    @IBOutlet weak var ivProduct: CustomImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblAddOns: UILabel!
    @IBOutlet weak var lblAddOnsPrice: UILabel!
    
    @IBOutlet weak var lblOtherDescr: UILabel!
}

class OrderHistoryDetailVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblOrder: UITableView!
    @IBOutlet weak var consTblHeight: NSLayoutConstraint!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblAddressTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblUserMobileNo: UILabel!
    @IBOutlet weak var lblResAddress: UILabel!
    @IBOutlet weak var lblTotalAmnt: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
    
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblMobileTitle: UILabel!
    @IBOutlet weak var lblStoreAddTitle: UILabel!
    
    @IBOutlet weak var lblDeliveryDate: UILabel!
    @IBOutlet weak var lblDeliveryDateTitle: UILabel!
    
    //MARK:- Global Variables
    var orderNo = ""
    var arrItemData = [[String:AnyObject]]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblOrder.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        
        lblNameTitle.text = Language.NAME
        lblAddressTitle.text = Language.ADDRESS
        lblMobileTitle.text = Language.MOBILE_NO
        lblStoreAddTitle.text = Language.RES_ADDRESS
        lblDeliveryDate.text = Language.DELIVERY_TIME
        
        callOrderDetailAPI()
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Other Functions
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]{
                let newsize  = newvalue as! CGSize
                consTblHeight.constant = newsize.height
            }
        }
    }
   
    //MARK:- Web Service Calling
    func callOrderDetailAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ORDER_DETAIL
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&order_number=\(self.orderNo)"
        
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
                        
                        //Getting data from API.
                        if let responseData = jsonObject["responsedata"] as?[String:AnyObject] {
                            
                            if let items = responseData["items"] as? [[String:AnyObject]] {
                                self.arrItemData = items
                            }
                            
                            self.tblOrder.reloadData()
                             
                            self.lblUsername.text = "\(UserModel.sharedInstance().firstname!) \(UserModel.sharedInstance().lastname!)"
                            
                            if let addressLine = responseData["address_line"] as? String, addressLine != "" {
                                self.lblAddress.text = addressLine
                            }else {
                                self.lblAddress.text = ""
                                self.lblAddressTitle.text = ""
                            }                           
                            
                            self.lblResAddress.text = responseData["res_address"] as? String
                            self.lblUserMobileNo.text = "+\(UserModel.sharedInstance().country_code!) \(UserModel.sharedInstance().mobileNo!)"
                            self.lblTotalAmnt.text = "\(Language.TOTAL_PAYABLE_AMT) : \(self.settingModel.currency ?? "")\(responseData["order_total"] as! String)"
                            self.lblDeliveryCharge.text = "\(Language.DELIVERY_CHARGE) : \(self.settingModel.currency ?? "")\(responseData["delivery_charge"] as! String)"
                            self.lblSubTotal.text = "\(Language.ITEM_TOTAL) : \(self.settingModel.currency ?? "")\(responseData["sub_total"] as! String)"
                            
                            if responseData["payment_type"] as! String == "cod" {
                            
                            
                            if let delivery_time = responseData["delivery_time"] as? String , delivery_time != "" {
                                self.lblDeliveryDate.text = delivery_time
                                self.lblDeliveryDateTitle.text = Language.DELIVERY_TIME
                            }else{
                                self.lblDeliveryDate.text = ""
                                self.lblDeliveryDateTitle.text = ""
                            }
                                
                            }else if responseData["payment_type"] as! String == "stripe" {
                                self.lblPaymentType.text = "\(Language.TYPE_OF_PAYMENT) : Stripe"
                                
                            }else if responseData["payment_type"] as! String == "paypal" {
                                self.lblPaymentType.text = "\(Language.TYPE_OF_PAYMENT) : Paypal"
                                
                            }else if responseData["payment_type"] as! String == "satispay" {
                                self.lblPaymentType.text = "\(Language.TYPE_OF_PAYMENT) : SatisPay"
                                
                            }else if responseData["payment_type"] as! String == "bancomat" {
                                self.lblPaymentType.text = "\(Language.TYPE_OF_PAYMENT) : Bancomat"
                            }
                            
                            if responseData["order_status"] as! String == "in_prepare" {
                                self.lblOrderStatus.text = Language.IN_PREPARE
                                
                            }else if responseData["order_status"] as! String == "pending" {
                                self.lblOrderStatus.text = Language.PENDING
                                
                            }else if responseData["order_status"] as! String == "decline" {
                                self.lblOrderStatus.text = Language.CANCELLED
                                
                            }else if responseData["order_status"] as! String == "decline" {
                                self.lblOrderStatus.text = Language.CANCELLED
                                
                            }else if responseData["order_status"] as! String == "delivery" {
                                self.lblOrderStatus.text = Language.DELIVERY
                                
                            }else {
                                self.lblOrderStatus.text = Language.COMPLETED
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
extension OrderHistoryDetailVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItemData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryItemCell") as! OrderHistoryItemCell
        
        cell.lblProductName.text = arrItemData[indexPath.row]["item_name"] as? String
        cell.lblDescription.text = arrItemData[indexPath.row]["category"] as? String
        
        if arrItemData[indexPath.row]["paid_customization"] as! String != "" {
            cell.lblAddOns.text = "\(Language.ADD_ON) : \(arrItemData[indexPath.row]["paid_customization"] as! String)"
            
            if arrItemData[indexPath.row]["add_ons_cust_price"] as! String != "" {
                cell.lblAddOnsPrice.text = arrItemData[indexPath.row]["add_ons_cust_price"] as? String
            }else {
                cell.lblAddOnsPrice.text = ""
            }
        }else {
            cell.lblAddOns.text = ""
            cell.lblAddOnsPrice.text = ""
        }
        
        var description = ""
        if let tasteCust = arrItemData[indexPath.row]["taste_customization"] as? String, tasteCust != "" {
            if description != "" {
                description = description + "\n\(Language.TASTE) : \(tasteCust)"
            }else {
                description = "\(Language.TASTE) : \(tasteCust)"
            }
        }
        
        if let cookCust = self.arrItemData[indexPath.row]["cooking_customization"] as? String, cookCust != "" {
            if description != "" {
                description = description + "\n\(Language.COOKING_LEVEL) : \(cookCust)"
            }else {
                description = "\(Language.COOKING_LEVEL) : \(cookCust)"
            }
        }
                
        if arrItemData[indexPath.row]["free_customization"] as! String != "" {
            description = description + "\n\(Language.REMOVE) : \(arrItemData[indexPath.row]["free_customization"] as! String)"
        }
        cell.lblOtherDescr.text = description
        
        cell.lblQty.text = "\(Language.QTY) : \(arrItemData[indexPath.row]["quantity"] as! String)"
        cell.lblPrice.text = "\(self.settingModel.currency ?? "")\(arrItemData[indexPath.row]["price"] as! String)"
        
        cell.ivProduct.sd_imageIndicator = self.getSDGrayIndicator()
        if let image = (self.arrItemData[indexPath.row])["item_image"] as? String, image != ""{
            cell.ivProduct.sd_setImage(with: URL(string: image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                cell.ivProduct.sd_imageIndicator = .none}
        }else{
            cell.ivProduct.image = UIImage(named: "noImage")
        }
        
        return cell
    }
    
}
