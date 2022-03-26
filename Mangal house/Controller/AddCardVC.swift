//
//  AddCardVC.swift
//  Mangal house
//
//  Created by Mahajan on 25/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit
import Stripe

class AddCardVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tfCardNumber: CustomTextField!
    @IBOutlet weak var tfCvvCode: CustomTextField!
    @IBOutlet weak var tfExpiryMonth: CustomTextField!
    @IBOutlet weak var tfExpiryYear: CustomTextField!
    
    @IBOutlet weak var lblCardNo: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCVV: UILabel!
    
    @IBOutlet weak var btnAdd: CustomButton!
    
    
    var arrExMonth = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    var arrExYear = [String]()
    
    //MARK:- Global Variables
    
    
    //MARK:- View Life Cyclepod 'Stripe', '~> 4.0'
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        for i in 0...20{
            self.arrExYear.append("\(year + i)")
            print(arrExYear)
        }
        
        lblCardNo.text = Language.CARD_NUMBER
        lblDate.text = Language.EXPIRY_DATE
        lblCVV.text = Language.CVV_CODE
        
        tfExpiryMonth.placeholder = Language.MONTH
        tfExpiryYear.placeholder = Language.YEAR
        tfCvvCode.placeholder = Language.CVV_CODE
        
        btnAdd.setTitle(Language.ADD, for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Other Functions
    func validation() -> Bool{
        if (tfCardNumber.text?.isEmpty)!{
            tfCardNumber.becomeFirstResponder()
            self.showError(Language.PROVIDE_CARD_NO)
            return false
        }else if (tfExpiryMonth.text?.isEmpty)!{
            self.showError(Language.SELECT_EXP_MONTH)
            return false
        }else if (tfExpiryYear.text?.isEmpty)!{
            self.showError(Language.SELECT_EXP_YEAR)
            return false
        }else if (tfCvvCode.text?.isEmpty)!{
            tfCvvCode.becomeFirstResponder()
            self.showError(Language.PROVIDE_CVV_CODE)
            return false
        }else{
            return true
        }
    }
    
    @IBAction func btnAdd_Action(_ sender: Any) {
        if validation(){
            callAddCard()
        }
    }
    
    //MARK:- Web Service Calling
    func callAddCard() {
        
        view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
//        let stripeCard = STPCard()
        
        // Send the card info to Strip to get the token
//        stripeCard.number = "\(tfCardNumber.text!)"
//        stripeCard.cvc = "\(tfCvvCode.text!)"
        
        let mnth = Int(tfExpiryMonth.text!)!
//        stripeCard.expMonth = UInt(mnth)
        
        let year = Int(tfExpiryYear.text!)!
//        stripeCard.expYear = UInt(year)
        
        
        
        let cardParams = STPCardParams()
        cardParams.number = "\(tfCardNumber.text!)"
        cardParams.expYear = UInt(year)
        cardParams.expMonth = UInt(mnth)
        cardParams.cvc = "\(tfCvvCode.text!)"
        
        
        STPAPIClient.shared.createToken(withCard: cardParams) { (token, error) in
                
            if error == nil{
                
                
                let serviceURL = Constant.WEBURL + Constant.API.ADD_CARD
                let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&cust_id=\(UserModel.sharedInstance().stripeCustId!)&token=\(token!.tokenId)"
                
                //Starting process to fetch the data.
                APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
                    
                    //Parsing method started to parse the data.
                    if let jsonObject = response.result.value as? [String:AnyObject] {
                        
                        //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                        if let status = jsonObject["status"] as? String {
                            if status == "0"{
                                print("Failed")
                                self.showError(jsonObject["message"] as! String)
                                //                                CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                            }else{
                                if let data = jsonObject["responsedata"] as? [String:AnyObject]{
                                    UserModel.sharedInstance().stripeCustId = data["cust_id"] as? String
                                }
                                UserModel.sharedInstance().synchroniseData()
                                //                                CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }) { (error) in
                    print(error)
                }
                
            }else{
                print(error)
            }
        }
        
    }
    
    //MARK:- UITextField Delegate Method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tfCardNumber{
            if (range.location == 19) {
                return false
            }
            
            if  (string.count == 0){
                return true
            }
            
            if ((range.location == 4) || (range.location == 9) || (range.location == 14)) {
                let str = "\(textField.text!)" + " "
                textField.text = str
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.tfCardNumber.resignFirstResponder()
        if textField == tfExpiryMonth{
            
            tfExpiryMonth.resignFirstResponder()
            tfExpiryMonth.tintColor = UIColor.clear
            ActionSheetStringPicker.show(withTitle: Language.SELECT_MONTH, rows: arrExMonth, initialSelection: 0, doneBlock: {
                picker, indexes, values in
                self.tfExpiryMonth.text = "\(values as! String)"
                
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: tfExpiryMonth)
            return false
            
        }
        
        if textField == tfExpiryYear{
            
            tfExpiryYear.resignFirstResponder()
            tfExpiryYear.tintColor = UIColor.clear
            ActionSheetStringPicker.show(withTitle: Language.SELECT_YEAR, rows: arrExYear, initialSelection: 0, doneBlock: {
                picker, indexes, values in
                self.tfExpiryYear.text = "\(values as! String)"
                
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: tfExpiryYear)
            return false
            
        }
        
        return true
    }
}


