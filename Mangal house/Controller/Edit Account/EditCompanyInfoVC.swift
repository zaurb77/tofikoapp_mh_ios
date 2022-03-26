//
//  EditCompanyInfoVC.swift
//  Mangal house
//
//  Created by Mahajan on 01/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class EditCompanyInfoVC: Main {
    
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
    
    //MARK:- Global Variables
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ivVat.image = UIImage(named: "vat_id")!.withRenderingMode(.alwaysTemplate)
        ivVat.tintColor = AppColors.golden
        
        ivCompany.image = UIImage(named: "company")!.withRenderingMode(.alwaysTemplate)
        ivCompany.tintColor = AppColors.golden
        
        ivInvoive.image = UIImage(named: "invoice_code")!.withRenderingMode(.alwaysTemplate)
        ivInvoive.tintColor = AppColors.golden
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }   
    
    //MARK:- Button Actions
    
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave_Action(_ sender: Any) {
        
    }
    
    //MARK:- Other Functions
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfName{
            self.vwName.layer.borderWidth = 2
            self.vwName.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfEmail{
            self.vwEmail.layer.borderWidth = 2
            self.vwEmail.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfVat{
            self.vwVat.layer.borderWidth = 2
            self.vwVat.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfInvoice{
            self.vwInvoice.layer.borderWidth = 2
            self.vwInvoice.layer.borderColor = AppColors.yellow.cgColor
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfName{
            self.vwName.layer.borderWidth = 1
            self.vwName.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfEmail{
            self.vwEmail.layer.borderWidth = 1
            self.vwEmail.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfVat{
            self.vwVat.layer.borderWidth = 1
            self.vwVat.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfInvoice{
            self.vwInvoice.layer.borderWidth = 1
            self.vwInvoice.layer.borderColor = AppColors.golden.cgColor
        }
    }
    
    
    
    //MARK:- Web Service Calling
    
    
    
}
