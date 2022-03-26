//
//  AddAddressVC.swift
//  Mangal house
//
//  Created by Mahajan on 24/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit
import GooglePlaces

class AddAddressVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnWork: UIButton!
    @IBOutlet weak var btnOther: UIButton!
    @IBOutlet weak var tfDoorNo: CustomTextField!
    @IBOutlet weak var tfAddress: CustomTextField!
    @IBOutlet weak var tfAddress2: CustomTextField!
    @IBOutlet weak var tfCity: CustomTextField!
    @IBOutlet weak var tfZipcode: CustomTextField!
    @IBOutlet weak var tfCountry: CustomTextField!
    @IBOutlet weak var btnSave: CustomButton!
    
    //MARK:- Global Variables
    var addressType = "home"
    var latitude = Double()
    var longitude = Double()
    var geocoder = CLGeocoder()
    var dictAddress = [String:AnyObject]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnHome.setTitle(Language.HOME, for: .normal)
        btnWork.setTitle(Language.WORK, for: .normal)
        btnOther.setTitle(Language.OTHER, for: .normal)
        btnSave.setTitle(Language.SAVE, for: .normal)
        
        tfAddress.placeholder = Language.ADDRESS
        tfAddress2.placeholder = Language.ADDRESS_LINE_2
        tfDoorNo.placeholder = Language.DOOR_NO
        tfCity.placeholder = Language.CITY
        tfZipcode.placeholder = Language.ZIPCODE
        tfCountry.placeholder = Language.COUNTRY
        
        if dictAddress.count > 0 {
            if let address_type = dictAddress["address_type"] as? String, address_type != "" {
                self.addressType = address_type
                
                if address_type == "home" {
                    btnHome.setImage(UIImage(named: "radioOn"), for: .normal)
                    btnWork.setImage(UIImage(named: "radioOff"), for: .normal)
                    btnOther.setImage(UIImage(named: "radioOff"), for: .normal)
                    
                }else if address_type == "work" {
                    btnWork.setImage(UIImage(named: "radioOn"), for: .normal)
                    btnHome.setImage(UIImage(named: "radioOff"), for: .normal)
                    btnOther.setImage(UIImage(named: "radioOff"), for: .normal)
                    
                }else {
                    btnOther.setImage(UIImage(named: "radioOn"), for: .normal)
                    btnWork.setImage(UIImage(named: "radioOff"), for: .normal)
                    btnHome.setImage(UIImage(named: "radioOff"), for: .normal)
                    
                }
            }
            
            if let doorNo = dictAddress["door_no"] as? String, doorNo != "" {
                self.tfDoorNo.text = doorNo
            }
            
            if let address = dictAddress["address"] as? String, address != "" {
                self.tfAddress.text = address
            }
            
            if let city = dictAddress["city"] as? String, city != "" {
                self.tfCity.text = city
            }
            
            if let zip_code = dictAddress["zip_code"] as? String, zip_code != "" {
                self.tfZipcode.text = zip_code
            }
            
            if let country = dictAddress["country"] as? String, country != "" {
                self.tfCountry.text = country
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Other Methods
    //Checking validation for add address screen.
    func checkValidation()->Bool{
        if tfDoorNo.text == ""{
            tfDoorNo.becomeFirstResponder()
            self.showError(Language.PROVIDE_DOOR_NO)
            return false
            
        }else if tfAddress.text == ""{
            tfAddress.becomeFirstResponder()
            self.showError(Language.PROVIDE_ADDRESS)
            return false
            
        }else if tfCity.text == ""{
            tfCity.becomeFirstResponder()
            self.showError(Language.PROVIDE_PROPER_CITY)
            return false
            
        }else if tfZipcode.text == ""{
            tfZipcode.becomeFirstResponder()
            self.showError(Language.PROVIDE_ZIP_CODE)
            return false
            
        }else if tfCountry.text == ""{
            tfCountry.becomeFirstResponder()
            self.showError(Language.SELECT_COUNTRY_NAME)
            return false
            
        }else if !(tfCity.text?.isValidName)!{
            tfCity.becomeFirstResponder()
            self.showError(Language.PROVIDE_PROPER_CITY)
            return false
            
        }else if !(tfZipcode.text?.isValidZipNumber)!{
            tfZipcode.becomeFirstResponder()
            self.showError(Language.PROVIDE_PROPER_ZIP)
            return false
            
        }else {
            return true
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave_Action(_ sender: Any) {
        if checkValidation() {
            if dictAddress.count > 0 {
                callChangeAddressAPI()
            }else {
                callAddAddressAPI()
            }
        }
    }
    
    @IBAction func btnHome_Action(_ sender: Any) {
        btnHome.setImage(UIImage(named: "radioOn"), for: .normal)
        btnWork.setImage(UIImage(named: "radioOff"), for: .normal)
        btnOther.setImage(UIImage(named: "radioOff"), for: .normal)
        
        addressType = "home"
    }
    
    @IBAction func btnWork_Action(_ sender: Any) {
        btnWork.setImage(UIImage(named: "radioOn"), for: .normal)
        btnHome.setImage(UIImage(named: "radioOff"), for: .normal)
        btnOther.setImage(UIImage(named: "radioOff"), for: .normal)
        
        addressType = "work"
    }
    
    @IBAction func btnOther_Action(_ sender: Any) {
        btnOther.setImage(UIImage(named: "radioOn"), for: .normal)
        btnWork.setImage(UIImage(named: "radioOff"), for: .normal)
        btnHome.setImage(UIImage(named: "radioOff"), for: .normal)
        
        addressType = "other"
    }
        
    //MARK:- Web Service Calling
    func callAddAddressAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ADDRESS
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&address_type=\(addressType)&address=\(tfAddress.text!)&address2=\(tfAddress2.text!)&door_no=\(tfDoorNo.text!)&city=\(tfCity.text!)&zip_code=\(tfZipcode.text!)&country=\(tfCountry.text!)&latitude=\(latitude)&longitude=\(longitude)&type=add"
                
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
                        self.showSuccess(jsonObject["message"] as! String)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callChangeAddressAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ADDRESS
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&address_type=\(addressType)&address=\(tfAddress.text!)&address2=\(tfAddress2.text!)&door_no=\(tfDoorNo.text!)&city=\(tfCity.text!)&zip_code=\(tfZipcode.text!)&country=\(tfCountry.text!)&latitude=\(latitude)&longitude=\(longitude)&address_id=\(dictAddress["address_id"] as! String)&type=edit"
                
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
                        self.showSuccess(jsonObject["message"] as! String)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

}

extension AddAddressVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        tfAddress.text = place.name
        latitude = place.coordinate.latitude
        longitude = place.coordinate.longitude
        
        let addressComponents = place.addressComponents
        
        for i in 0..<addressComponents!.count {
            let component = addressComponents![i]
            print(component)
            
            if component.types.contains("locality") {
                self.tfCity.text = component.name
            }
            
            if component.types.contains("country") {
                self.tfCountry.text = component.name
            }
            
            if component.types.contains("postal_code") {
                self.tfZipcode.text = component.name
            }
        }
        
        if tfZipcode.text!.isEmpty {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Unable to Reverse Geocode Location (\(error))")
                    self.showError(Language.UNABLE_TO_FIND_ADD)

                } else {
                    if let placemarks = placemarks, let placemark = placemarks.first {
                        self.tfZipcode.text = placemark.postalCode
                    } else {
                        self.showError(Language.ADDRESS_NOT_FOUNDED)
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    //User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension AddAddressVC {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfAddress{
            let placePickerController = GMSAutocompleteViewController()
            placePickerController.delegate = self
            present(placePickerController, animated: true, completion: nil)
            return false
        }else{
            return true
        }
    }
}
