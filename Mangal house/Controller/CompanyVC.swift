//
//  CompanyVC.swift
//  Mangal house
//
//  Created by Mahajan on 01/01/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class CompanyVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var ivVat: UIImageView!
    @IBOutlet weak var ivInvoive: UIImageView!
    @IBOutlet weak var ivCompany: UIImageView!
    
    @IBOutlet weak var vwName: CustomUIView!
    @IBOutlet weak var vwVat: CustomUIView!
    @IBOutlet weak var vwEmail: CustomUIView!
    @IBOutlet weak var vwInvoice: CustomUIView!
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfVat: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfInvoice: UITextField!
    
    @IBOutlet weak var btnSave: CustomButton!
    
    
    //MARK:- Global Variables
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfName.placeholder = Language.COMPANY_NAME
        tfVat.placeholder = Language.VAT_ID
        tfEmail.placeholder = Language.LEGAL_EMAIL
        tfInvoice.placeholder = Language.UNIQUE_INVOICE_CODE
        
        ivVat.image = UIImage(named: "vat_id")!.withRenderingMode(.alwaysTemplate)
        ivVat.tintColor = AppColors.golden
        
        ivCompany.image = UIImage(named: "company")!.withRenderingMode(.alwaysTemplate)
        ivCompany.tintColor = AppColors.golden
        
        ivInvoive.image = UIImage(named: "invoice_code")!.withRenderingMode(.alwaysTemplate)
        ivInvoive.tintColor = AppColors.golden
        
        if UserModel.sharedInstance().companyId != nil && UserModel.sharedInstance().companyId! == "0" {
            btnSave.setTitle("Add", for: .normal)
        }else {
            
            //Setting company name in the company name field
            if UserModel.sharedInstance().companyName != nil && UserModel.sharedInstance().companyName! != "" {
                tfName.text = UserModel.sharedInstance().companyName!
            }
            
            //Setting vat ID in the vat ID field
            if UserModel.sharedInstance().vatId != nil && UserModel.sharedInstance().vatId! != "" {
                tfVat.text = UserModel.sharedInstance().vatId!
            }
            
            //Setting company legal email field in the company legal email field
            if UserModel.sharedInstance().companyLegalEmail != nil && UserModel.sharedInstance().companyLegalEmail! != "" {
                tfEmail.text = UserModel.sharedInstance().companyLegalEmail!
            }
            
            //Setting unique invoice code in the unique invoice code field
            if UserModel.sharedInstance().uniqueInvoiceCode != nil && UserModel.sharedInstance().uniqueInvoiceCode! != "" {
                tfInvoice.text = UserModel.sharedInstance().uniqueInvoiceCode!
            }
            
            btnSave.setTitle(Language.SAVE, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNext_Action(_ sender: Any) {
        if checkValidation() {
            callCompanyAddressService()
        }
    }
    
    //MARK:- Other Mehtods
    //Validation checker method - Use to check the validation of controls.
    func checkValidation()->Bool{
        if tfName.text == "" {
            tfName.becomeFirstResponder()
            self.showError(Language.PROVIDE_COM_NAME)
            return false
        }else if tfVat.text == "" {
            tfVat.becomeFirstResponder()
            self.showError(Language.PROVIDE_VAT_ID)
            return false
        }else if tfEmail.text == "" {
            tfEmail.becomeFirstResponder()
            self.showError(Language.PROVIDE_EMAIL)
            return false
        }else if tfInvoice.text == "" {
            tfInvoice.becomeFirstResponder()
            self.showError(Language.PROVIDE_INVOICE)
            return false
        }else if !tfEmail.text!.isEmail {
            tfInvoice.becomeFirstResponder()
            self.showError(Language.VAILD_EMAIL)
            return false
        }else {
            return true
        }
    }
    
    //MARK:- Web Service Calling
    func callCompanyAddressService() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        var companyId = "0"
        if UserModel.sharedInstance().companyId != nil && UserModel.sharedInstance().companyId! != "0" {
            companyId = UserModel.sharedInstance().companyId!
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_COMPANY
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&company_legal_email=\(tfEmail.text!)&unique_invoicing_code=\(tfInvoice.text!)&company_name=\(tfName.text!)&vat_id=\(tfVat.text!)&company_id=\(companyId)"
        
        //Starting process to change company information detail.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String {
                    if status == "0"{
                        print("Failed")
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            UserModel.sharedInstance().companyId = responseData["company_id"] as? String
                            UserModel.sharedInstance().companyName = responseData["company_name"] as? String
                            UserModel.sharedInstance().companyLegalEmail = responseData["company_legal_email"] as? String
                            UserModel.sharedInstance().uniqueInvoiceCode = responseData["unique_invoicing_code"] as? String
                            UserModel.sharedInstance().vatId = responseData["vat_id"] as? String
                            UserModel.sharedInstance().synchroniseData()
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.showWarning(Language.WENT_WRONG)
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
}
