//
//  CheckoutVC.swift
//  Mangal house
//
//  Created by Mahajan on 25/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit
import AVFoundation

class CardCell: UITableViewCell{
    @IBOutlet weak var ivTick: UIImageView!
    @IBOutlet weak var lblCard: UILabel!
}

class CheckoutVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var btnNow: UIButton!
    @IBOutlet weak var btnLater: UIButton!
    @IBOutlet weak var cnsBtnNowWidth: NSLayoutConstraint!
    
    @IBOutlet weak var tblCard: UITableView!
    @IBOutlet weak var consTblCardHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblResName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblAddressTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var lblRestNo: UILabel!
    
    @IBOutlet weak var lblLaterTime: UILabel!
    @IBOutlet weak var lblItemTotal: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    @IBOutlet weak var lblTotalAmnt: UILabel!
    @IBOutlet weak var lblMangalAmnt: UILabel!
    
    @IBOutlet weak var ivCod: UIImageView!
    @IBOutlet weak var ivPaypal: UIImageView!
    @IBOutlet weak var ivSatispay: UIImageView!
    @IBOutlet weak var ivBancomat: UIImageView!
    
    @IBOutlet weak var cnsVwMangalHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnInvoice: UIButton!
    @IBOutlet weak var btnCompany: UIButton!
    
    @IBOutlet weak var lblResNameTitle: UILabel!
    @IBOutlet weak var lblUsernameTitle: UILabel!
    @IBOutlet weak var lblMobileNoTitle: UILabel!
    @IBOutlet weak var lblResNumberTitle: UILabel!
    @IBOutlet weak var lblChooseDeliveryTime: UILabel!
    @IBOutlet weak var lblCreditDebit: UILabel!
    @IBOutlet weak var btnAddNewCard: UIButton!
    @IBOutlet weak var lblCODTItle: UILabel!
    @IBOutlet weak var lblCash: UILabel!
    @IBOutlet weak var lblKeepCash: UILabel!
    @IBOutlet weak var lblPayDelivery: UILabel!
    @IBOutlet weak var lblItemTotalTitle: UILabel!
    @IBOutlet weak var lblDeliveryChargeTitle: UILabel!
    @IBOutlet weak var lblPayAmntTitle: UILabel!
    
    @IBOutlet weak var btnOrder: UIButton!
    
    @IBOutlet weak var lblAddNewCard: UILabel!
    
    
    //MARK:- Global Variables
    var totalAmnt = ""
    var totalPayAmnt = ""
    var deliveryCharge = ""
    var note = ""
    var resName = ""
    var address = ""
    var resMobileNo = ""
    var resIsOpen = ""
    var time = ""
    var selectedType = ""
    var isCutlery = ""
    var addressID = ""
    var mangalPrice = ""
    var isMangalCart = ""
    
    var arrSavedCard = [[String:String]]()
    var selectedCardID = ""
    
    var deliveryType = "now"
    var paymentType = ""
    var isInvoice = "0"
           
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblResName.text = resName
        lblUsername.text = "\(UserModel.sharedInstance().firstname!) \(UserModel.sharedInstance().lastname!)"
        
        lblMobileNo.text = "+\(UserModel.sharedInstance().country_code!) \(UserModel.sharedInstance().mobileNo!)"
        lblRestNo.text = resMobileNo
        lblTotalAmnt.text = "\(self.settingModel.currency ?? "")\(totalPayAmnt)"
        lblItemTotal.text = "\(self.settingModel.currency ?? "")\(totalAmnt)"
        lblDeliveryCharge.text = "\(self.settingModel.currency ?? "")\(deliveryCharge)"
        
        if isMangalCart == "1" {
            cnsVwMangalHeight.constant = 40
            lblMangalAmnt.text = mangalPrice
        }else {
            cnsVwMangalHeight.constant = 0
        }
        
        if resIsOpen == "2" {
            cnsBtnNowWidth.constant = 0
            
            btnNow.setImage(UIImage(named: "radioOff"), for: .normal)
            btnLater.setImage(UIImage(named: "radioOn"), for: .normal)
            
            var arrTime = [String]()
            
             let timeFormat = DateFormatter()
             timeFormat.dateFormat = "HH:mm"
                   
             var fromDate = timeFormat.date(from: time)
             fromDate = fromDate?.addingTimeInterval(2400)
                         
             var dateByAddingThirtyMinute = fromDate
             for _ in 0..<12 {
                 var formattedDateString: String?
                 let dateFormatter = DateFormatter()
                 dateFormatter.dateFormat = "HH:mm"
                 if let dateByAddingThirtyMinute = dateByAddingThirtyMinute {
                     formattedDateString = dateFormatter.string(from: dateByAddingThirtyMinute)
                 }
                 arrTime.append(formattedDateString!)
                 
                 dateByAddingThirtyMinute = fromDate?.addingTimeInterval(300)
                 fromDate = dateByAddingThirtyMinute
             }
             
            self.lblLaterTime.text = arrTime[0]
            
            
        }else {
            cnsBtnNowWidth.constant = 90
        }
        
        if selectedType == "0" {
            lblAddressTitle.text = ""
            lblAddress.text = ""
            
            lblTotalAmnt.text = "\(self.settingModel.currency ?? "")\(totalAmnt)"
            lblItemTotal.text = "\(self.settingModel.currency ?? "")\(totalAmnt)"
            lblDeliveryCharge.text = "\(self.settingModel.currency ?? "")0.00"
        }else {
            lblAddressTitle.text = Language.ADDRESS
            lblAddress.text = address
            
            lblTotalAmnt.text = "\(self.settingModel.currency ?? "")\(totalPayAmnt)"
            lblItemTotal.text = "\(self.settingModel.currency ?? "")\(totalAmnt)"
            lblDeliveryCharge.text = "\(self.settingModel.currency ?? "")\(deliveryCharge)"
        }
        
        tblCard.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        
        lblResNameTitle.text = Language.RES_NAME
        lblUsernameTitle.text = Language.NAME
        
        lblMobileNoTitle.text = Language.MOBILE_NUMBER
        lblResNumberTitle.text = Language.RES_NUMBER
        lblChooseDeliveryTime.text = "   \(Language.CHOOSE_DELIVERY_TIME)"
        
        btnNow.setTitle(Language.NOW, for: .normal)
        btnLater.setTitle(Language.LATER, for: .normal)
        
        lblCreditDebit.text = "   \(Language.CREDIT_DEBIT_CARD)"
        lblAddNewCard.text = Language.ADD_NEW_CARD
        
        lblCODTItle.text = "   \(Language.CASH_ON_DELIVERY)"
        lblCash.text = Language.CASH
        lblKeepCash.text = Language.KEEP_CASH_ON_HAND
        
//        lblPayDelivery.text = "   \(Language.PAY_ON_DELIVERY)"
        lblItemTotalTitle.text = Language.ITEM_TOTAL
        lblDeliveryChargeTitle.text = Language.DELIVERY_CHARGE
        lblPayAmntTitle.text = Language.TOTAL_PAYABLE_AMT
        
        btnInvoice.setTitle(Language.ADD_INVOICE, for: .normal)
        btnOrder.setTitle(Language.ORDER, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        callCardListAPI()
        
        setStatusBarColor(AppColors.golden)
        
        if UserModel.sharedInstance().companyId != nil && UserModel.sharedInstance().companyId! != "0" {
            btnCompany.setTitle(Language.CHANGE, for: .normal)
        }else {
            btnCompany.setTitle(Language.ADD, for: .normal)
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNow_Action(_ sender: Any) {
        deliveryType = "Now"
        btnNow.setImage(UIImage(named: "radioOn"), for: .normal)
        btnLater.setImage(UIImage(named: "radioOff"), for: .normal)
    }
    
    @IBAction func btnLater_Action(_ sender: Any) {
        deliveryType = "Later"
             btnNow.setImage(UIImage(named: "radioOff"), for: .normal)
             btnLater.setImage(UIImage(named: "radioOn"), for: .normal)
             
             if resIsOpen == "2" {
                 
                 var arrTimes = [String]()
                     
                 let timeFormat = DateFormatter()
                 timeFormat.dateFormat = "HH:mm"
                       
                 var fromDate = timeFormat.date(from: time)
                 fromDate = fromDate?.addingTimeInterval(2400)
                             
                 var dateByAddingThirtyMinute = fromDate
                 for _ in 0..<12 {
                     var formattedDateString: String?
                     let dateFormatter = DateFormatter()
                     dateFormatter.dateFormat = "HH:mm"
                     if let dateByAddingThirtyMinute = dateByAddingThirtyMinute {
                         formattedDateString = dateFormatter.string(from: dateByAddingThirtyMinute)
                     }
                     arrTimes.append(formattedDateString!)
                     
                     dateByAddingThirtyMinute = fromDate?.addingTimeInterval(300)
                     fromDate = dateByAddingThirtyMinute
                 }
                 
                
                 ActionSheetStringPicker.show(withTitle: "Select Time", rows : arrTimes , initialSelection: 0, doneBlock: {
                     picker, value, index in
                     self.lblLaterTime.text = arrTimes[value]
                     return
                 }, cancel: { ActionStringCancelBlock in
                     return
                     
                 }, origin: self.view)
                 
             }else if resIsOpen == "1" {
                             
                 var arrTimes = [String]()
                 let timeFormat = DateFormatter()
                 timeFormat.dateFormat = "HH:mm:ss"
                       
                 var fromTime: Date?
                 let rounded = Date(timeIntervalSinceReferenceDate: (Date().timeIntervalSinceReferenceDate / 1800.0).rounded(.toNearestOrEven) * 1800.0)
                 let todayTime = timeFormat.string(from: rounded)
                 fromTime = timeFormat.date(from: todayTime)
        
                 for _ in 0..<12 {
                     let dateByAddingThirtyMinute = fromTime?.addingTimeInterval(300)
                     fromTime = dateByAddingThirtyMinute
                     var formattedDateString: String?
                     let dateFormatter = DateFormatter()
                     dateFormatter.dateFormat = "HH:mm"
                     if let dateByAddingThirtyMinute = dateByAddingThirtyMinute {
                         formattedDateString = dateFormatter.string(from: dateByAddingThirtyMinute)
                     }
                     arrTimes.append(formattedDateString!)
                     
                 }
                 
                ActionSheetStringPicker.show(withTitle: Language.SELECT_TIME, rows : arrTimes , initialSelection: 0, doneBlock: {
                     picker, value, index in
                     self.lblLaterTime.text = arrTimes[value]
                     return
                 }, cancel: { ActionStringCancelBlock in
                     return
                     
                 }, origin: self.view)
             }
    }
    
   
    
    @IBAction func btnAddNewCard_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toAddCard", sender: nil)
    }
    
    @IBAction func btnCompany_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toCompany", sender: nil)
    }
    
    @IBAction func btnOrder_Action(_ sender: Any) {
        
        if isInvoice == "1" && UserModel.sharedInstance().companyId != nil && UserModel.sharedInstance().companyId == "0" {
            self.showError(Language.ENTER_COMPANY_INFO)
            
        }else {
            if paymentType == "" {
                self.showError(Language.PROVIDE_PAYMENT_TYPE)
                
            }else if deliveryType == "" {
                self.showError(Language.SELECT_TIME_ERROR)
                
            }else if deliveryType == "Later" && lblLaterTime.text!.isEmpty {
                self.showError(Language.SELECT_TIME_ERROR)
                
            }else {
                callCheckoutAPI()
            }
        }
    }
    
    @IBAction func btnCOD_Action(_ sender: Any) {
        paymentType = "cod"
        ivCod.image = UIImage(named: "checkmark")
        ivPaypal.image = UIImage(named: "radioOff")
        ivSatispay.image = UIImage(named: "radioOff")
        ivBancomat.image = UIImage(named: "radioOff")
        tblCard.reloadData()
    }
    
    @IBAction func btnPaypal_Action(_ sender: Any) {
        paymentType = "paypal"
        ivPaypal.image = UIImage(named: "checkmark")
        ivCod.image = UIImage(named: "radioOff")
        ivSatispay.image = UIImage(named: "radioOff")
        ivBancomat.image = UIImage(named: "radioOff")
        tblCard.reloadData()
    }
    
    @IBAction func btnBancomat_Action(_ sender: Any) {
        paymentType = "bancomat"
        ivSatispay.image = UIImage(named: "radioOff")
        ivCod.image = UIImage(named: "radioOff")
        ivPaypal.image = UIImage(named: "radioOff")
        ivBancomat.image = UIImage(named: "checkmark")
        tblCard.reloadData()
    }
    
    @IBAction func btnSatispay_Action(_ sender: Any) {
        paymentType = "satispay"
        ivSatispay.image = UIImage(named: "checkmark")
        ivCod.image = UIImage(named: "radioOff")
        ivPaypal.image = UIImage(named: "radioOff")
        ivBancomat.image = UIImage(named: "radioOff")
        tblCard.reloadData()
    }
    
    @IBAction func btnInvoice_Action(_ sender: Any) {
        if isInvoice == "1" {
            isInvoice = "0"
            btnCompany.isHidden = true
            btnInvoice.setImage(UIImage(named: "checkboxEmpty"), for: .normal)
        }else {
            isInvoice = "1"
            btnCompany.isHidden = false
            btnInvoice.setImage(UIImage(named: "checkboxFill"), for: .normal)
        }
    }
    
    
    //MARK:- Other Functions
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]{
                let newsize  = newvalue as! CGSize
                consTblCardHeight.constant = newsize.height
            }
        }
    }
    
    //MARK:- Web Service Calling
    func callCardListAPI() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CARD_LIST
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&cust_id=\(UserModel.sharedInstance().stripeCustId!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.arrSavedCard.removeAll()
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:String]] {
                            self.arrSavedCard = responseData
                        }
                    }
                    
                    self.tblCard.reloadData()
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callCheckoutAPI() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        var cartId = ""
        if self.settingModel.cart_id != nil {
            cartId = self.settingModel.cart_id
        }
                
        var orderType = ""
        if selectedType == "1" {
            orderType = "delivery"
        }else {
            orderType = "pickup"
        }
        
        if selectedCardID == "-1" {
            selectedCardID = ""
        }
                
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CHECKOUT
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&type=\(paymentType)&cart_id=\(cartId)&delivery_type=\(deliveryType)&delivery_note=\(note)&delivery_time=\(lblLaterTime.text!)&order_type=\(orderType)&is_invoice=\(isInvoice)&is_cutlery=\(isCutlery)&address_id=\(addressID)&is_mangals=\(isMangalCart)&card_id=\(selectedCardID)"
                
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                    }else{
                        print(jsonObject)
                        
                        
                        
                        if self.paymentType == "stripe" || self.paymentType == "cod" || self.paymentType == "bancomat"{
                            
                            UserModel.sharedInstance().isPaypalCheckout = nil
                            UserModel.sharedInstance().synchroniseData()
                            
                            self.performSegue(withIdentifier: "toAck", sender: nil)
                            
                        }else {
                            if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                                if let url = responseData["url"] as? String, url != "" {
                                    guard let url = URL(string: url) else { return }
                                    UIApplication.shared.open(url)
                                    
                                    UserModel.sharedInstance().isPaypalCheckout = "true"
                                    UserModel.sharedInstance().synchroniseData()
                                    
                                    (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
                                    
                                }else {
                                    self.performSegue(withIdentifier: "toAck", sender: nil)
                                }
                             }
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

}

extension CheckoutVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSavedCard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
        
        cell.lblCard.text = "**** **** **** \(arrSavedCard[indexPath.row]["card_number"]!)"
        
        if selectedCardID == arrSavedCard[indexPath.row]["card_id"]! && paymentType == "stripe"{
            cell.ivTick.image = UIImage(named: "checkmark")
        }else {
            cell.ivTick.image = UIImage(named: "radioOff")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! CardCell

        if cell.ivTick.image == UIImage(named: "radioOff") {
            if arrSavedCard.count > 0{
                paymentType = "stripe"
                self.selectedCardID = ((arrSavedCard[indexPath.row])["card_id"])!
                cell.ivTick.image = UIImage(named: "checkmark")
            }

        }else {
            self.selectedCardID = "-1"
            cell.ivTick.image = UIImage(named: "radioOff")
        }

        tblCard.reloadData()

        if self.selectedCardID != "-1" {
            ivCod.image = UIImage(named: "radioOff")
            ivPaypal.image = UIImage(named: "radioOff")
        }
    }
}
