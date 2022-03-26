//
//  OrderListVC.swift
//  Mangal house
//
//  Created by Mahajan on 24/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit

class CartListCell : UITableViewCell{
    @IBOutlet weak var cnsWidthIvProd: NSLayoutConstraint!
    @IBOutlet weak var ivProduct: CustomImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductCategory: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblQty: UILabel!
    
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var cnsMangalLogoWidth: NSLayoutConstraint!
}

class CartVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblOrderList: UITableView!
    @IBOutlet weak var consTblHeight: NSLayoutConstraint!
    @IBOutlet weak var btnDelivery: UIButton!
    @IBOutlet weak var btnTakeway: UIButton!
    @IBOutlet weak var btnCutleryOrder: UIButton!
    
    @IBOutlet weak var tvSpecialRequest: CustomTextView!
    
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var cnsIvLocationHeight: NSLayoutConstraint!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var cnsBtnAddressHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var btnPayMangal: UIButton!
    @IBOutlet weak var cnsHeightPayMangal: NSLayoutConstraint!
    
    @IBOutlet weak var lblMangalPrice: UILabel!
    @IBOutlet weak var cnsHeightVwMangal: NSLayoutConstraint!
    
    @IBOutlet weak var lblItemTotal: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    
    @IBOutlet weak var cnsLblResErrorHeight: NSLayoutConstraint!
    @IBOutlet weak var lblResError: UILabel!
    
    @IBOutlet weak var cnsBtnCheckoutHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ivRightArrow: UIImageView!
    
    //MARK:- Global Variables
    var isCutlery = 0
    var orderType = 1
    var payMangal = 0
    var arrCartItems = [[String:AnyObject]]()
    var addressId = ""
    var cartDictData = [String:AnyObject]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tvSpecialRequest.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tblOrderList.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        callCartListAPI()
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDelivery_Action(_ sender: Any) {
        orderType = 1
        setOrderType()
    }
    
    @IBAction func btnTakeway_Action(_ sender: Any) {
        orderType = 0
        setOrderType()
    }
    
    @IBAction func btnCutleryOrder_Action(_ sender: Any) {
        if isCutlery == 1 {
            btnCutleryOrder.setImage(UIImage(named: "checkboxEmpty"), for: .normal)
            isCutlery = 0
        }else{
            btnCutleryOrder.setImage(UIImage(named: "checkboxFill"), for: .normal)
            isCutlery = 0
        }
    }
    
    @IBAction func btnChangeAddress_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toAdd", sender: nil)
    }
    
    @IBAction func btnCheckout_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toCheckout", sender: nil)
        
        if orderType == 0 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutVC") as! CheckoutVC
            vc.totalAmnt = cartDictData["order_total"] as! String
            vc.totalPayAmnt = cartDictData["total_pay_amount"] as! String
            vc.deliveryCharge = cartDictData["delivery_charge"] as! String
            vc.note = self.tvSpecialRequest.text!
            vc.resName = cartDictData["restaurant_name"] as! String
            vc.address = ""
            vc.resMobileNo = cartDictData["restaurant_phone"] as! String
            vc.resIsOpen = cartDictData["res_is_open"] as! String
            vc.time = cartDictData["next_open_time"] as! String
            vc.selectedType = "\(orderType)"
            vc.isCutlery = "\()"
            vc.totalPayAmnt = cartDictData["total_pay_amount"] as! String
            vc.totalPayAmnt = cartDictData["total_pay_amount"] as! String
            vc.totalPayAmnt = cartDictData["total_pay_amount"] as! String
            self.navigationController?.pushViewController(vc, animated: true)
            
                
            .putExtra("time", pojo.responsedata.next_open_time)
            .putExtra("SELECTED_TYPE", "" + selectedTYpe)
            .putExtra("IS_CUTLERY", "" + isCutlery)
            .putExtra("ADDRESS_ID", addressId)
            .putExtra("MANGAL_PRICE", pojo.responsedata.mangal_all_item_total)
            .putExtra("is_mangal_cart", mangalPay));
        
        }else {

            if addressId == "" {
                self.showWarning("Error", "Please select a delivery address.")
                
           }else {
                startActivity(new Intent(activity, PaymentInfoScreen.class)
                        .putExtra("totalAmount", pojo.responsedata.order_total)
                        .putExtra("totalPayAmount", pojo.responsedata.total_pay_amount)
                        .putExtra("deliveryCharges", pojo.responsedata.delivery_charge)
                        .putExtra("totalPayable", pojo.responsedata.total_pay_amount)
                        .putExtra("isMangals", "" + pojo.responsedata.is_mangals_cart)
                        .putExtra("note", getIntent().getStringExtra("note"))
                        .putExtra("RES_NAME", pojo.responsedata.restaurant_name)
                        .putExtra("USER_NAME", storeUserData.getString(Constants.USER_FNAME) + " " + storeUserData.getString(Constants.USER_LNAME))
                        .putExtra("ADDRESS", binding.address.getText().toString())
                        .putExtra("MOBILE_NO", storeUserData.getString(Constants.mobile_no))
                        .putExtra("res_is_open", "" + pojo.responsedata.res_is_open)
                        .putExtra("time", pojo.responsedata.next_open_time)
                        .putExtra("RESTAURANT_MOBILE_NO", pojo.responsedata.restaurant_phone)
                        .putExtra("SELECTED_TYPE", "" + selectedTYpe)
                        .putExtra("IS_CUTLERY", "" + isCutlery)
                        .putExtra("ADDRESS_ID", addressId)
                        .putExtra("MANGAL_PRICE", pojo.responsedata.mangal_all_item_total)
                        .putExtra("is_mangal_cart", mangalPay));
            }
        }
        
    }
    
    @IBAction func btnPayMangal_Action(_ sender: Any) {
        if payMangal == 1 {
            payMangal = 0
            btnPayMangal.setImage(UIImage(named: "switch-off"), for: .normal)
        }else {
            payMangal = 1
            btnPayMangal.setImage(UIImage(named: "switch-on"), for: .normal)
        }
        
        callCartListAPI()
    }
    
    @objc func btnPlus_Action(_ sender: UIButton) {
        
        let newQty = Int(arrCartItems[sender.tag]["quantity"] as! String)! + 1
        callChangeQtyAPI(arrCartItems[sender.tag]["cart_item_id"] as! String, "\(newQty)")
        
    }
    
    @objc func btnMinus_Action(_ sender: UIButton) {
        let newQty = Int(arrCartItems[sender.tag]["quantity"] as! String)! - 1
        callChangeQtyAPI(arrCartItems[sender.tag]["cart_item_id"] as! String, "\(newQty)")
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
    
    func setOrderType() {
        if orderType == 1 {
            cnsIvLocationHeight.constant = 25
            cnsBtnAddressHeight.constant = 40
            lblAddress.text = "125, Yagnik Road, Gondal Road, Rajkot, Gujarat, India 3600013"
            
            btnDelivery.setImage(UIImage(named: "radioOn"), for: .normal)
            btnTakeway.setImage(UIImage(named: "radioOff"), for: .normal)
            
            if settingModel.orderType == "pickup" {
                cnsIvLocationHeight.constant = 0
                cnsBtnAddressHeight.constant = 0
                lblAddress.text = ""
                btnAddress.setTitle("SELECT ADDRESS", for: .normal)
                
            }else {
                btnAddress.setTitle("CHANGE ADDRESS", for: .normal)
            }
            
        }else {
            cnsIvLocationHeight.constant = 0
            cnsBtnAddressHeight.constant = 0
            lblAddress.text = ""
            
            btnTakeway.setImage(UIImage(named: "radioOn"), for: .normal)
            btnDelivery.setImage(UIImage(named: "radioOff"), for: .normal)
        }
        
        
    }
   
    
    //MARK:- Web Service Calling
    func callCartListAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning("Warning", "Please check your internet connection")
            return
        }
             
        var cartId = ""
        if self.settingModel.cart_id != nil {
            cartId = self.settingModel.cart_id
        }
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: Date())
        
        df.dateFormat = "EEEE"
        let dayName = df.string(from: Date())
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CART_ITEMS
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&cart_id=\(cartId)&is_mangals=\(payMangal)&time=\(time)&day=\(dayName.lowercased())"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showWarning("Error", jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            self.cartDictData = responseData
                            
                            if let cartItems = responseData["items"] as? [[String:AnyObject]], cartItems.count > 0 {
                                self.arrCartItems = cartItems
                            }else {
                                self.arrCartItems.removeAll()
                            }
                            
                            self.tblOrderList.reloadData()
                            
                            if self.payMangal == 1 {
                                self.cnsHeightVwMangal.constant = 20
                                
                                if let mangalPrice = responseData["mangal_all_item_total"] as? String, mangalPrice != "" {
                                    self.lblMangalPrice.text = mangalPrice
                                }
                                
                            }else {
                                self.cnsHeightVwMangal.constant = 0
                                self.lblMangalPrice.text = "0"
                            }
                            
                            if let isMangalCart = responseData["is_mangals_cart"] as? String, isMangalCart == "1" {
                                self.cnsHeightPayMangal.constant = 40
                            }else {
                                self.cnsHeightPayMangal.constant = 0
                            }
                            
//                            binding.llEmptyCart.setVisibility(View.GONE);
//                            binding.llMain.setVisibility(View.VISIBLE);
                            
                            self.lblTotalPrice.text = "€\(responseData["total_pay_amount"] as! String)"
                            self.lblItemTotal.text = "€\(responseData["order_total"] as! String)"
                            self.lblDeliveryCharge.text = "€\(responseData["delivery_charge"] as! String)"
                            
                            self.settingModel.orderType = responseData["order_type"] as? String
                            self.lblAddress.text = responseData["restaurant_address"] as? String

                            if responseData["address_id"] as! String != "0" {
                                self.addressId = responseData["address_id"] as! String
                            }else {
                                self.addressId = ""
                            }
                            
                            if self.settingModel.orderType != "" {
                                
                                if self.settingModel.orderType == "delivery" {
                                    self.orderType = 1
                                }else {
                                    self.orderType = 0
                                    self.addressId = ""
                                }
                                
                                self.setOrderType()
                            }

                            if let resIsOpen = responseData["res_is_open"] as? String {
                                if resIsOpen == "0" {
                                    self.cnsBtnCheckoutHeight.constant = 0
                                    self.ivRightArrow.isHidden = true
                                    self.cnsLblResErrorHeight.constant = 50
                                    self.lblResError.text = responseData["res_open_error"] as? String
                                }else {
                                    self.cnsBtnCheckoutHeight.constant = 50
                                    self.ivRightArrow.isHidden = false
                                    self.cnsLblResErrorHeight.constant = 0
                                    self.lblResError.text = ""
                                }
                            }else {
                                self.cnsBtnCheckoutHeight.constant = 50
                                self.ivRightArrow.isHidden = false
                                self.cnsLblResErrorHeight.constant = 0
                                self.lblResError.text = ""
                            }

                        }
                        
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callChangeQtyAPI(_ itemID: String, _ qty: String) {
            
            self.view.endEditing(true)
            
            //Checking for internet connection. If internet is not available then system will display toast message.
            guard NetworkManager.shared.isConnectedToNetwork() else {
                self.showWarning("Warning", "Please check your internet connection")
                return
            }
                 
            var cartId = ""
            if self.settingModel.cart_id != nil {
                cartId = self.settingModel.cart_id
            }
        
            //Creating API request to fetch the data.
            let serviceURL = Constant.WEBURL + Constant.API.CHANGE_QTY
            let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&cart_id=\(cartId)&cart_item_id=\(itemID)&quantity=\(qty)"
            
            //Starting process to fetch the data and store default login data.
            APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
                
                //Parsing method started to parse the data.
                if let jsonObject = response.result.value as? [String:AnyObject] {
                    CommonFunctions().hideLoader()
                    
                    if let status = jsonObject["status"] as? String{
                        if status == "0"{
                            print("Failed")
                            self.showWarning("Error", jsonObject["message"] as! String)
                            
                        }else{
                            print(jsonObject)
                            
                            if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                                
                                if let orderTotal = responseData["order_total"] as? String, orderTotal == "0" {
                                    self.settingModel.cart_id = ""
                                }
                                
                                self.callCartListAPI()
                            }
                        }
                    }
                }
                
            }) { (error) in
                print(error)
            }
        }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAdd" {
            let destVC = segue.destination as! AddressListVC
            destVC.comeFrom = "CHANGE_ADDRESS"
        }
    }

}
extension CartVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartListCell") as! CartListCell
        
        if self.arrCartItems[indexPath.row]["image_enable"] as! String == "0" {
            cell.cnsWidthIvProd.constant = 0
        }else {
            cell.cnsWidthIvProd.constant = 80
            
            cell.ivProduct.sd_imageIndicator = self.getSDWhiteIndicator()
            cell.ivProduct.sd_setImage(with: URL(string: ((self.arrCartItems[indexPath.row])["item_image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                cell.ivProduct.sd_imageIndicator = .none
            }
        }
        
        cell.lblProductName.text = self.arrCartItems[indexPath.row]["item_name"] as? String
        cell.lblProductCategory.text = self.arrCartItems[indexPath.row]["category"] as? String
        cell.lblQty.text = self.arrCartItems[indexPath.row]["quantity"] as? String
        
        var strDesc = ""
        if let paidCust = self.arrCartItems[indexPath.row]["paid_customization"] as? String, paidCust != "" {
            strDesc = "Add On : \(paidCust)"
        }
        
        if let freeCust = self.arrCartItems[indexPath.row]["free_customization"] as? String, freeCust != "" {
            if strDesc != "" {
                strDesc = strDesc + "\nRemove : \(freeCust)"
            }else {
                strDesc = "Remove : \(freeCust)"
            }
        }
        cell.lblDescription.text = strDesc
        
        
        if self.arrCartItems[indexPath.row]["is_offered"] as! String == "1" {
            
            if self.arrCartItems[indexPath.row]["mangal_remain_price"] as! String == "0" && self.arrCartItems[indexPath.row]["need_mangals"] as! String != "0" {
                cell.cnsMangalLogoWidth.constant = 20
                cell.lblPrice.text = self.arrCartItems[indexPath.row]["need_mangals"] as? String
                
            }else if self.arrCartItems[indexPath.row]["mangal_remain_price"] as! String == "0" {
                cell.cnsMangalLogoWidth.constant = 0
                cell.lblPrice.text = "€\(self.arrCartItems[indexPath.row]["main_price"] as! String)"
                
            }else {
                cell.cnsMangalLogoWidth.constant = 20
                cell.lblPrice.text = "€\(self.arrCartItems[indexPath.row]["mangal_remain_price"] as! String) + \(self.arrCartItems[indexPath.row]["need_mangals"] as! String)"
            }
            
        }else {
            cell.cnsMangalLogoWidth.constant = 0
            cell.lblPrice.text = "€\(self.arrCartItems[indexPath.row]["main_price"] as! String)"
        }
        
        cell.btnPlus.tag = indexPath.row
        cell.btnPlus.addTarget(self, action: #selector(btnPlus_Action(_:)), for: .touchUpInside)
        
        cell.btnMinus.tag = indexPath.row
        cell.btnMinus.addTarget(self, action: #selector(btnMinus_Action(_:)), for: .touchUpInside)
        
        return cell
        
    }
    
}
