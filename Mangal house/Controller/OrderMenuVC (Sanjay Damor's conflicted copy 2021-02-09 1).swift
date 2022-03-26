//
//  OrderVC.swift
//  Mangal house
//
//  Created by Mahajan on 24/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit

class MenuCategoryCell: UICollectionViewCell{
    @IBOutlet weak var ivCategory: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivSelect: CustomImageView!
    
}

class MenuTblItemCell: UITableViewCell{
    
    
}

class MenuCvItemCell: UICollectionViewCell{
    @IBOutlet weak var consVwAddWidth: NSLayoutConstraint!
    @IBOutlet weak var btnAddItem: UIButton!
    
    @IBOutlet weak var cnsIvSpicyWidth: NSLayoutConstraint!
    @IBOutlet weak var cnsIvVegWidth: NSLayoutConstraint!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var ivProduct: UIImageView!
    
    @IBOutlet weak var consVwQtyWidth: NSLayoutConstraint!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblCustomizable: UILabel!
    @IBOutlet weak var consLblSeeMoreWidth: NSLayoutConstraint!
}

class OrderMenuVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var cvCategory: UICollectionView!
    @IBOutlet weak var cvOrder: UICollectionView!
    @IBOutlet weak var tblorder: UITableView!
    @IBOutlet weak var vwCategory: UIView!
    @IBOutlet weak var btnChangeLayout: UIButton!
    
    @IBOutlet weak var lblQty: CustomLabel!
    @IBOutlet weak var lblTotal: UILabel!
    
    @IBOutlet weak var lblResError: UILabel!
    @IBOutlet weak var cnsResErrorHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tfSearch: CustomTextField!
    @IBOutlet weak var cnsVwSearchHeight: NSLayoutConstraint!
    
    @IBOutlet var vwCatEmpty: UIView!
    
    
    //MARK:- Global Variables
    var isLayoutGrid = true
    var orderType = ""
    var resId = ""
    var selectedAddressId = ""
    
    var catID = ""
    var arrCatData = [[String:AnyObject]]()
    
    var arrMenuData = [[String:AnyObject]]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        vwCategory.layer.cornerRadius = 10
        vwCategory.layer.shadowColor = UIColor.lightGray.cgColor
        vwCategory.layer.shadowOffset = CGSize(width: -1, height: 1)
        vwCategory.layer.shadowOpacity = 0.7
        vwCategory.layer.shadowRadius = 4.0
        
        tfSearch.layer.masksToBounds = false
        tfSearch.layer.shadowRadius = 10.0
        tfSearch.layer.shadowColor = UIColor(red: 31/255, green: 84/255, blue: 195/255, alpha: 0.15).cgColor
        tfSearch.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        tfSearch.layer.shadowOpacity = 1.0
        
        if settingModel.menu_search == "1" {
            cnsVwSearchHeight.constant = 40
        }else {
            cnsVwSearchHeight.constant = 0
        }
        
        self.view.addSubview(vwCatEmpty)
        vwCatEmpty.frame = CGRect(x: 0, y: self.view.frame.minY + 100.0, width: self.view.frame.width, height: self.view.frame.height - 100.0)
        vwCatEmpty.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        
        if resId != "" {
            callCheckCartAPI(resId)
        }else {
            callCheckCartAPI(settingModel.near_res_id)
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnNext_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toOrderList", sender: nil)
    }
    
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChangeLayout_Action(_ sender: Any) {
        if isLayoutGrid{
            btnChangeLayout.setImage(UIImage(named: "grid"), for: .normal)
            isLayoutGrid = false
            self.cvOrder.isHidden = true
            self.tblorder.isHidden = false
        }else{
            btnChangeLayout.setImage(UIImage(named: "list"), for: .normal)
            isLayoutGrid = true
            self.cvOrder.isHidden = false
            self.tblorder.isHidden = true
        }
    }
    
    @objc func btnAddItem_Action(_ sender: UIButton){
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "CustomizationVC") as? CustomizationVC
            else {
                return
        }
        present(popupVC, animated: true, completion: nil)
    }
    
    //MARK:- Other Functions
    func callAPI() {
        if catID != "" {
            if resId != "" {
                callItemAPI(resId)
            }else {
                callItemAPI(settingModel.near_res_id)
            }
        }else {
            if resId != "" {
                callCategoryAPI(resId)
            }else {
                callCategoryAPI(settingModel.near_res_id)
            }
        }
    }
    
    //MARK:- Web Service Calling
    func callCheckCartAPI(_ resID: String) {
        
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
        let serviceURL = Constant.WEBURL + Constant.API.CHECK_CART_AVAILIBILITY
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&cart_id=\(cartId)&res_id=\(resID)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        self.lblQty.text = ""
                        self.lblQty.isHidden = true
                        self.lblTotal.text = ""
                        
                        self.callCategoryAPI(resID)
                        
                    }else {
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            if let cartItems = responseData["cart_items"] as? String {
                                self.lblQty.text = "\(cartItems)"
                                self.lblQty.isHidden = false
                            }else {
                                self.lblQty.text = ""
                                self.lblQty.isHidden = true
                            }
                            
                            if let finalTotal = responseData["final_total"] as? String, finalTotal != "0.00" {
                                self.lblTotal.text = "Total | €\(finalTotal)"
                            }else {
                                self.lblTotal.text = ""
                            }
                        }
                        
                        self.callCategoryAPI(resID)
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

    func callCategoryAPI(_ resID: String) {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning("Warning", "Please check your internet connection")
            return
        }
                
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: Date())
        
        df.dateFormat = "EEEE"
        let dayName = df.string(from: Date())
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.RESTAURANT_CATEGORY
        let params = "?time=\(time)&day=\(dayName)&restaurant_id=\(resID)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        
                        self.vwCatEmpty.isHidden = false
                        
                    }else {
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]] {
                            self.arrCatData = responseData
                        }
                        
                        if self.arrCatData.count > 0 {
                            self.vwCatEmpty.isHidden = true
                            self.catID = self.arrCatData[0]["id"] as! String
                            self.callItemAPI(resID)
                        }else {
                            self.vwCatEmpty.isHidden = false
                        }
                        
                        if let resError = jsonObject["res_open_error"] as? String {
                            self.lblResError.text = resError
                            self.cnsResErrorHeight.constant = 40
                        }else {
                            self.lblResError.text = ""
                            self.cnsResErrorHeight.constant = 0
                        }
                        
                        self.cvCategory.reloadData()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callItemAPI(_ resID: String) {
        
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
        let serviceURL = Constant.WEBURL + Constant.API.RESTAURANT_MENU_ITEMS
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&restaurant_id=\(resID)&cat_id=\(catID)&cart_id=\(cartId)"
        
        //Starting process to fetch the data
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        
                        self.vwCatEmpty.isHidden = false
                        
                    }else {
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]] {
                            self.arrMenuData = responseData
                        }
                        
                        if self.arrCatData.count > 0 {
                            self.vwCatEmpty.isHidden = true
                            self.catID = self.arrCatData[0]["id"] as! String
                        }else {
                            self.vwCatEmpty.isHidden = false
                        }
                        
                        if let resError = jsonObject["res_open_error"] as? String {
                            self.lblResError.text = resError
                            self.cnsResErrorHeight.constant = 40
                        }else {
                            self.lblResError.text = ""
                            self.cnsResErrorHeight.constant = 0
                        }
                        
                        self.cvOrder.reloadData()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
}

extension OrderMenuVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == cvCategory {
            return arrCatData.count
        }else{
            return arrMenuData.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == cvCategory {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCategoryCell", for: indexPath) as! MenuCategoryCell
            
            cell.ivCategory.sd_imageIndicator = getSDWhiteIndicator()
            cell.ivCategory.sd_setImage(with: URL(string: ((self.arrCatData[indexPath.row])["image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                cell.ivCategory.sd_imageIndicator = .none
            }
            cell.lblName.text = self.arrCatData[indexPath.row]["name"] as? String
            
            if catID == self.arrCatData[indexPath.row]["id"] as! String {
                cell.ivSelect.isHidden = false
            }else {
                cell.ivSelect.isHidden = true
            }
            
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCvItemCell", for: indexPath) as! MenuCvItemCell
            
            let dictData = arrMenuData[indexPath.row]
            
            if dictData["image_enable"] as! String == "1" {
                cell.ivProduct.sd_imageIndicator = getSDWhiteIndicator()
                cell.ivProduct.sd_setImage(with: URL(string: (dictData["image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                    cell.ivProduct.sd_imageIndicator = .none
                }
            }else {
                cell.ivProduct.image = UIImage(named: "noImage")
            }
            
            cell.lblName.text = dictData["name"] as? String
            cell.lblPrice.text = dictData["name"] as? String
            if let ingredients = dictData["ingredients"] as? String, ingredients != "" {
                cell.lblDesc.text = ingredients.html2String
                cell.consLblSeeMoreWidth.constant = 55
            }else {
                cell.lblDesc.text = ""
                cell.consLblSeeMoreWidth.constant = 0
            }
            
            
            
            
            cell.btnAddItem.tag = indexPath.row
            cell.btnAddItem.addTarget(self, action: #selector(btnAddItem_Action(_:)), for: .touchUpInside)
            
            
            
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvCategory {
            catID = self.arrCatData[indexPath.row]["id"] as! String
            self.cvCategory.reloadData()
            
            if resId != "" {
                callItemAPI(resId)
            }else {
                callItemAPI(settingModel.near_res_id)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == cvCategory{
            return CGSize(width: 90, height: 80)
        }else{
            return CGSize(width: (self.cvOrder.frame.size.width - 20) / 2, height: self.cvOrder.frame.size.width / 2)
        }
        
    }
    
}
extension OrderMenuVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTblItemCell") as! MenuTblItemCell
        
        
        
        return cell
    }
    
}
