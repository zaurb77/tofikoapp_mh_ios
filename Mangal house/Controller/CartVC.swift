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
    @IBOutlet weak var lblAddOns: UILabel!
    @IBOutlet weak var lblAddOnsPrice: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblQty: UILabel!
    
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var cnsMangalLogoWidth: NSLayoutConstraint!
}

class CartVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var scrView: UIScrollView!
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
    
    @IBOutlet weak var lblNoteCnt: UILabel!
    
    @IBOutlet weak var mangalSwitch: UISwitch!
    @IBOutlet weak var btnPayMangal: UIButton!
    @IBOutlet weak var cnsHeightPayMangal: NSLayoutConstraint!
    
    @IBOutlet weak var lblMangalPrice: UILabel!
    @IBOutlet weak var cnsHeightVwMangal: NSLayoutConstraint!
    
    @IBOutlet weak var lblItemTotal: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    
    @IBOutlet weak var lblResError: UILabel!
    @IBOutlet weak var cnsVwResErrorHeight: NSLayoutConstraint!
    @IBOutlet weak var ivLeftError: CustomImageView!
    @IBOutlet weak var ivRightError: CustomImageView!
    
    
    @IBOutlet weak var cnsBtnCheckoutHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ivRightArrow: UIImageView!

    @IBOutlet weak var vwEmpty: UIView!
    
    @IBOutlet weak var lblTotalPayAmntTitle: UILabel!
    @IBOutlet weak var lblOrderTypeTitle: UILabel!
    @IBOutlet weak var lblSpeReqTitle: UILabel!
    @IBOutlet weak var lblMangalsTitle: UILabel!
    @IBOutlet weak var lblPayMangalTitle: UILabel!
    @IBOutlet weak var lblItemTotalTitle: UILabel!
    @IBOutlet weak var lblDeliveryChargeTitle: UILabel!
    @IBOutlet weak var lblCartEmpty: UILabel!
    @IBOutlet weak var lblWoops: UILabel!
    @IBOutlet weak var btnBackMainMenu: CustomButton!
    
    
    @IBOutlet weak var btnCheckout: UIButton!
    
    //MARK:- Global Variables
    var isFrom = ""
    var isCutlery = 0
    var orderType = 1
    var payMangal = 0
    var arrCartItems = [[String:AnyObject]]()
    var addressId = ""
    var cartDictData = [String:AnyObject]()
    var isCalledAPIOnce = false
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tvSpecialRequest.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tblOrderList.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        self.navigationController?.isNavigationBarHidden = true
        
        lblTotalPayAmntTitle.text = Language.TOTAL_PAYABLE_AMT
        lblOrderTypeTitle.text = Language.ORDER_TYPE
        lblSpeReqTitle.text = Language.SPECIAL_REQUEST
        lblPayMangalTitle.text = Language.PAY_WITH_MANGAL
        lblItemTotalTitle.text = Language.ITEM_TOTAL
        lblDeliveryChargeTitle.text = Language.DELIVERY_CHARGE
        btnDelivery.setTitle(Language.DELIVERY, for: .normal)
        btnTakeway.setTitle(Language.TAKEAWAY, for: .normal)
        btnCutleryOrder.setTitle(Language.ADD_CUTLERY, for: .normal)
        btnAddress.setTitle(Language.CHANGE_ADDRESS.uppercased(), for: .normal)
        btnCheckout.setTitle(Language.CHECKOUT, for: .normal)
        
        lblCartEmpty.text = Language.CART_EMPTY
        lblWoops.text = Language.WOOPS
        btnBackMainMenu.setTitle(Language.BACK_MAIN_MENU, for: .normal)
        
        callCartListAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        if navigationController == nil {
            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
        }else {
            if arrCartItems.count == 0 || isFrom == "address" || isFrom == "menu" {
                self.navigationController?.popToRootViewController(animated: true)
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func btnDelivery_Action(_ sender: Any) {
        self.settingModel.orderType = "delivery"
        self.lblTotalPrice.text = "\(self.settingModel.currency ?? "")\(self.cartDictData["total_pay_amount"] as! String)"
        self.lblDeliveryCharge.text = "\(self.settingModel.currency ?? "")\(self.cartDictData["delivery_charge"] as! String)"
        orderType = 1
        setOrderType()
    }
    
    @IBAction func btnTakeway_Action(_ sender: Any) {
        self.settingModel.orderType = "pickup"
        self.lblTotalPrice.text = "\(self.settingModel.currency ?? "")\(self.cartDictData["order_total"] as! String)"
        self.lblDeliveryCharge.text = "\(self.settingModel.currency ?? "")0.00"
        orderType = 0
        setOrderType()
    }
    
    @IBAction func btnCutleryOrder_Action(_ sender: Any) {
        if isCutlery == 1 {
            btnCutleryOrder.setImage(UIImage(named: "checkboxEmpty"), for: .normal)
            isCutlery = 0
        }else{
            btnCutleryOrder.setImage(UIImage(named: "checkboxFill"), for: .normal)
            isCutlery = 1
        }
    }
    
    @IBAction func btnChangeAddress_Action(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressListVC")  as! AddressListVC
        vc.comeFrom = "CHANGE_ADDRESS"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCheckout_Action(_ sender: Any) {
        
        let totalPayAmnt = Double(cartDictData["total_pay_amount"] as! String)!
        let minAmnt = Double(cartDictData["min_order"] as! String)!
        
        if orderType == 1 && addressId == "" {
            self.showWarning(Language.DELIVERY_ADDRESS)
            
        }else if orderType == 1 && totalPayAmnt < minAmnt{
            self.showWarning("\(Language.MINIMUM_ORDER_AMOUNT) \(minAmnt)")
            
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutVC") as! CheckoutVC
            vc.totalAmnt = cartDictData["order_total"] as! String
            vc.totalPayAmnt = cartDictData["total_pay_amount"] as! String
            vc.deliveryCharge = cartDictData["delivery_charge"] as! String
            vc.note = self.tvSpecialRequest.text!
            vc.resName = cartDictData["restaurant_name"] as! String
            vc.resMobileNo = cartDictData["restaurant_phone"] as! String
            vc.resIsOpen = cartDictData["res_is_open"] as! String
            vc.time = cartDictData["next_open_time"] as! String
            vc.selectedType = "\(orderType)"
            vc.isCutlery = "\(isCutlery)"
            if(orderType == 0) {
                vc.addressID = ""
                vc.address = ""
            }else {
                vc.addressID = self.addressId
                vc.address = self.lblAddress.text!
            }
            vc.mangalPrice = cartDictData["mangal_all_item_total"] as! String
            vc.isMangalCart = "\(payMangal)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
                
    }
    
    @IBAction func btnPayMangalSwitch_Action(_ sender: UISwitch) {
        
        if sender.isOn {
            payMangal = 1
        }else {
            payMangal = 0
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
    
    
    @IBAction func btnBackToMainMenu_Action(_ sender: CustomButton) {
        (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
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
            
            if let address = cartDictData["address"] as? String, address != ""{
                cnsIvLocationHeight.constant = 25
                lblAddress.text = address
                btnAddress.setTitle(Language.CHANGE_ADDRESS.uppercased(), for: .normal)
            }else{
                btnAddress.setTitle(Language.SELECT_ADDRESS.uppercased(), for: .normal)
                cnsIvLocationHeight.constant = 0
            }
            
            cnsBtnAddressHeight.constant = 40
            btnDelivery.setImage(UIImage(named: "radioOn"), for: .normal)
            btnTakeway.setImage(UIImage(named: "radioOff"), for: .normal)
            
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
            self.showWarning(Language.CHECK_INTERNET)
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
                                         
                        self.arrCartItems.removeAll()
                        self.scrView.isHidden = true
                        self.vwEmpty.isHidden = false
                        
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
                                
                                if self.isCalledAPIOnce == false {
                                    self.isCalledAPIOnce = true
                                    
                                    self.cnsHeightPayMangal.constant = 50
                                    self.payMangal = 1
                                    self.mangalSwitch.isOn = true
                                    
                                    self.callCartListAPI()
                                }
                                
                            }else {
                                self.cnsHeightPayMangal.constant = 0
                                self.payMangal = 0
                                self.mangalSwitch.isOn = false
                            }
                            
                            self.scrView.isHidden = false
                            self.vwEmpty.isHidden = true
                            
                            self.lblTotalPrice.text = "\(self.settingModel.currency ?? "")\(responseData["total_pay_amount"] as! String)"
                            self.lblItemTotal.text = "\(self.settingModel.currency ?? "")\(responseData["order_total"] as! String)"
                            
                            
                            self.settingModel.orderType = responseData["order_type"] as? String

                            if responseData["address_id"] as! String != "0" {
                                self.addressId = responseData["address_id"] as! String
                                self.lblAddress.text = responseData["address"] as? String
                                self.cnsIvLocationHeight.constant = 25
                            }else {
                                self.addressId = ""
                                self.lblAddress.text = ""
                                self.cnsIvLocationHeight.constant = 0
                            }
                            
                            if self.settingModel.orderType != "" {
                                
                                if self.settingModel.orderType == "delivery" {
                                    self.orderType = 1
                                    self.lblDeliveryCharge.text = "\(self.settingModel.currency ?? "")\(responseData["delivery_charge"] as! String)"
                                }else {
                                    self.orderType = 0
                                    self.lblDeliveryCharge.text = "\(self.settingModel.currency ?? "") 0.00"
                                    self.addressId = ""
                                }
                                
                                self.setOrderType()
                            }

                            if let resIsOpen = responseData["res_is_open"] as? String {
                                if resIsOpen == "0" {
                                    self.cnsBtnCheckoutHeight.constant = 0
                                    self.ivRightArrow.isHidden = true
                                    self.lblResError.text = responseData["res_open_error"] as? String
                                    
                                    self.cnsVwResErrorHeight.constant = 50
                                    if let preOrderAccept = responseData["pre_order_accept"] as? String, preOrderAccept != "" {
                                        
                                        if preOrderAccept == "1" {
                                            self.ivLeftError.backgroundColor = UIColor(red: 64/255, green: 173/255, blue: 48/255, alpha: 1.0)
                                            self.ivRightError.backgroundColor = UIColor(red: 64/255, green: 173/255, blue: 48/255, alpha: 1.0)
                                        }else if preOrderAccept == "0" {
                                            self.ivLeftError.backgroundColor = UIColor(red: 176/255, green: 51/255, blue: 63/255, alpha: 1.0)
                                            self.ivRightError.backgroundColor = UIColor(red: 176/255, green: 51/255, blue: 63/255, alpha: 1.0)
                                        }
                                    }
                                    
                                }else {
                                    self.cnsBtnCheckoutHeight.constant = 50
                                    self.ivRightArrow.isHidden = false
                                    self.cnsVwResErrorHeight.constant = 0
                                    self.lblResError.text = ""
                                }
                            }else {
                                self.cnsBtnCheckoutHeight.constant = 50
                                self.ivRightArrow.isHidden = false
                                self.cnsVwResErrorHeight.constant = 0
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
            self.showWarning(Language.CHECK_INTERNET)
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
                        self.showError(jsonObject["message"] as! String)
                        
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
        
        if self.arrCartItems[indexPath.row]["is_offered"] as! String == "1" {
            
            cell.cnsWidthIvProd.constant = 80
            cell.ivProduct.sd_imageIndicator = self.getSDGrayIndicator()
            
            if let item_image = (self.arrCartItems[indexPath.row])["item_image"] as? String, item_image != ""{
                cell.ivProduct.sd_setImage(with: URL(string: item_image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                    cell.ivProduct.sd_imageIndicator = .none}
            }else{
                cell.ivProduct.image = UIImage(named: "noImage")
            }
            
        }else {
            if self.arrCartItems[indexPath.row]["image_enable"] as! String == "0" {
                cell.cnsWidthIvProd.constant = 0
            }else {
                cell.cnsWidthIvProd.constant = 80
                
                cell.ivProduct.sd_imageIndicator = self.getSDGrayIndicator()
                if let item_image = (self.arrCartItems[indexPath.row])["item_image"] as? String, item_image != ""{
                    cell.ivProduct.sd_setImage(with: URL(string: item_image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                        cell.ivProduct.sd_imageIndicator = .none}
                }else{
                    cell.ivProduct.image = UIImage(named: "noImage")
                }
                
            }
        }
                
        cell.lblProductName.text = self.arrCartItems[indexPath.row]["item_name"] as? String
        cell.lblProductCategory.text = self.arrCartItems[indexPath.row]["category"] as? String
        cell.lblQty.text = self.arrCartItems[indexPath.row]["quantity"] as? String
        
        
        if let paidCust = self.arrCartItems[indexPath.row]["paid_customization"] as? String, paidCust != "", let paidCustPrice = self.arrCartItems[indexPath.row]["add_ons_price"] as? String {
//            if strDesc != "" {
//                strDesc = strDesc + "\n\(Language.ADD_ON) : \(paidCust)"
//            }else {
//                strDesc = "\(Language.ADD_ON) : \(paidCust)"
//            }
            
            cell.lblAddOns.text = "\(Language.ADD_ON) : \(paidCust)"
            cell.lblAddOnsPrice.text = paidCustPrice
        }else {
            cell.lblAddOns.text = ""
            cell.lblAddOnsPrice.text = ""
        }
        
        var strDesc = ""
        if let tasteCust = self.arrCartItems[indexPath.row]["taste_customization"] as? String, tasteCust != "" {
            strDesc = "\(Language.TASTE) : \(tasteCust)"
        }
        
        if let cookCust = self.arrCartItems[indexPath.row]["cooking_customization"] as? String, cookCust != "" {
            if strDesc != "" {
                strDesc = strDesc + "\n\(Language.COOKING_LEVEL) : \(cookCust)"
            }else {
                strDesc = "\(Language.COOKING_LEVEL) : \(cookCust)"
            }
        }
                        
        if let freeCust = self.arrCartItems[indexPath.row]["free_customization"] as? String, freeCust != "" {
            if strDesc != "" {
                strDesc = strDesc + "\n\(Language.REMOVE) : \(freeCust)"
            }else {
                strDesc = "\(Language.REMOVE) : \(freeCust)"
            }
        }
        cell.lblDescription.text = strDesc
        
        
        if self.arrCartItems[indexPath.row]["is_offered"] as! String == "1" {
            
            if self.arrCartItems[indexPath.row]["mangal_remain_price"] as! String == "0" && self.arrCartItems[indexPath.row]["need_mangals"] as! String != "0" {
                cell.cnsMangalLogoWidth.constant = 20
                cell.lblPrice.text = self.arrCartItems[indexPath.row]["need_mangals"] as? String
                
            }else if self.arrCartItems[indexPath.row]["mangal_remain_price"] as! String == "0" {
                cell.cnsMangalLogoWidth.constant = 0
                cell.lblPrice.text = "\(self.settingModel.currency ?? "")\(self.arrCartItems[indexPath.row]["main_price"] as! String)"
                
            }else {
                cell.cnsMangalLogoWidth.constant = 20
                cell.lblPrice.text = "\(self.settingModel.currency ?? "")\(self.arrCartItems[indexPath.row]["mangal_remain_price"] as! String) + \(self.arrCartItems[indexPath.row]["need_mangals"] as! String)"
            }
            
        }else {
            cell.cnsMangalLogoWidth.constant = 0
            cell.lblPrice.text = "\(self.settingModel.currency ?? "")\(self.arrCartItems[indexPath.row]["main_price"] as! String)"
        }
        
        cell.btnPlus.tag = indexPath.row
        cell.btnPlus.addTarget(self, action: #selector(btnPlus_Action(_:)), for: .touchUpInside)
        
        cell.btnMinus.tag = indexPath.row
        cell.btnMinus.addTarget(self, action: #selector(btnMinus_Action(_:)), for: .touchUpInside)
        
        return cell
        
    }
    
}
extension CartVC : UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let count = textView.text.count + (text.count - range.length)
        if count <= 256 {
            self.lblNoteCnt.text = "\(count)/256"
            return true
        }else {
            return false
        }
        
    }
}
