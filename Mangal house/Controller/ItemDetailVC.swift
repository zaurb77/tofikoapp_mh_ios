//
//  ItemDetailVC.swift
//  Mangal house
//
//  Created by Mahajan on 09/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import SDWebImage

class CollectionImageCell: UICollectionViewCell {
    @IBOutlet weak var ivProduct: UIImageView!
}

class ItemDetailVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var ivItem: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var consVwAddHeight: NSLayoutConstraint!
    @IBOutlet weak var consVwQtyHeight: NSLayoutConstraint!
    @IBOutlet weak var lblQty: UILabel!
    
    @IBOutlet weak var lblIngredientsTitle: UILabel!
    @IBOutlet weak var lblIngredients: UILabel!
    @IBOutlet weak var lblAllergensTitle: UILabel!
    @IBOutlet weak var lblAllergens: UILabel!
    
    @IBOutlet weak var lblDescTitle: UILabel!
    @IBOutlet weak var lblCompanyDesc: UILabel!
    
    @IBOutlet weak var lblURL: UILabel!
    @IBOutlet weak var lblManufacturer: UILabel!
    @IBOutlet weak var lblPublisher: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    
    @IBOutlet weak var ivBarCode: UIImageView!
    @IBOutlet weak var ivISBN: UIImageView!
    
    @IBOutlet weak var lblItemName: UILabel!
    
    @IBOutlet weak var consVwBarcodeHeight: NSLayoutConstraint!
    @IBOutlet weak var consVwISBNHeight: NSLayoutConstraint!
    @IBOutlet weak var consVwURLHeight: NSLayoutConstraint!
    @IBOutlet weak var consVwManufacturerHeight: NSLayoutConstraint!
    @IBOutlet weak var consVwPublisherHeight: NSLayoutConstraint!
    @IBOutlet weak var consVwSizeHeight: NSLayoutConstraint!
    
    @IBOutlet weak var consIvMangal: NSLayoutConstraint!
    @IBOutlet weak var consItemImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var vwAdd: CustomUIView!
    
    @IBOutlet weak var cnsCvHeight: NSLayoutConstraint!
    @IBOutlet weak var cvImages: UICollectionView!
    
    //MARK:- Global Variables
    var comeFrom = ""
    var orderType = ""
    var itemId = ""
    var resId = ""
    var selectedAddressId = ""
    var dictData = [String:AnyObject]()
    var arrImages = [String]()
    
    var preOrderAccept = ""
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAdd.setTitle(Language.ADD, for: .normal)
        
        callItemDetail()
   
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(urlAction))
        lblURL.addGestureRecognizer(tapGesture)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        if self.comeFrom == "BANNER_ITEM_COMBO" || self.comeFrom == "BANNER_ITEM" {
            self.navigationController?.popToRootViewController(animated: true)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnAdd_Action(_ sender: Any) {
        let arrRemoveCust = dictData["remove_customization"] as! [[String:AnyObject]]
        let arrCust = dictData["customization"] as! [[String:AnyObject]]
        let arrTaste = dictData["taste"] as! [[String:AnyObject]]
        let arrCookingGrade = dictData["cooking_grades"] as! [[String:AnyObject]]
        
        if arrRemoveCust.count == 0 && arrCust.count == 0 && arrTaste.count == 0 && arrCookingGrade.count == 0 {
            callAddToCartAPI("", "", "", "")
            
        }else {
            customizationDialog(true, arrRemoveCust, arrCust, arrTaste, arrCookingGrade)
        }
    }
    
    @IBAction func btnPlus_Action(_ sender: Any) {
        let arrRemoveCust = dictData["remove_customization"] as! [[String:AnyObject]]
        let arrCust = dictData["customization"] as! [[String:AnyObject]]
        let arrTaste = dictData["taste"] as! [[String:AnyObject]]
        let arrCookingGrade = dictData["cooking_grades"] as! [[String:AnyObject]]
        
        if arrRemoveCust.count == 0 && arrCust.count == 0 && arrTaste.count == 0 && arrCookingGrade.count == 0 {
            var qty = 0
            if dictData["quantity"] as! String != "" && dictData["quantity"] as! String != "0" {
                qty = Int(dictData["quantity"] as! String)!
            }
            callChangeQtyAPI(dictData["cart_item_id"] as! String, "\(qty + 1)")
            
        }else {
            if dictData["is_taste"] as! String == "1" {
                customizationDialog(true, arrRemoveCust, arrCust, arrTaste, arrCookingGrade)
            }else {
                customizationDialog(false, arrRemoveCust, arrCust, arrTaste, arrCookingGrade)
            }
        }
    }
    
    @IBAction func btnMinus_Action(_ sender: Any) {
        let arrCartItems = dictData["cart_items"] as! [[String:AnyObject]]
        
        if arrCartItems.count > 1 {
            
            guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "RemoveCartItemVC") as? RemoveCartItemVC
                else {
                    return
            }
            popupVC.delegate = self
            popupVC.itemID = self.itemId
            present(popupVC, animated: true, completion: nil)
            
        }else {
            var qty = 0
            if dictData["quantity"] as! String != "" && dictData["quantity"] as! String != "0" {
                qty = Int(dictData["quantity"] as! String)!
            }
            callChangeQtyAPI(dictData["cart_item_id"] as! String, "\(qty - 1)")
        }
    }
    
    @IBAction func btnLeft_Action(_ sender: Any) {
        let visibleItems: NSArray = self.cvImages.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.lastObject as! IndexPath
        let prevItem: IndexPath = IndexPath(item: currentItem.item - 1, section: 0)
        if prevItem.row < arrImages.count {
            self.cvImages.scrollToItem(at: prevItem, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func btnRight_Action(_ sender: Any) {
        //        let visibleItems: NSArray = self.cvImages.indexPathsForVisibleItems as NSArray
        //        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        //        let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
        //        if nextItem.row < arrImages.count {
        //            self.cvImages.scrollToItem(at: nextItem, at: .centeredHorizontally, animated: true)
        //        }
        
        
        if let coll  = cvImages {
            for cell in coll.visibleCells {
                let indexPath: IndexPath? = coll.indexPath(for: cell)
                if ((indexPath?.row)! < arrImages.count - 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                    
                    coll.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    coll.scrollToItem(at: indexPath1!, at: .left, animated: true)
                }
                
            }
        }
        
//        guard let indexPath = cvImages.indexPathsForVisibleItems.first.flatMap({
//            IndexPath(item: $0.row + 1, section: $0.section)
//        }), cvImages.cellForItem(at: indexPath) != nil else {
//            return
//        }
//
//        cvImages.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    @objc func urlAction(_ sender: UITapGestureRecognizer) {
        guard let url = URL(string: lblURL.text!) else { return }
        UIApplication.shared.open(url)
    }
    
    //MARK:- Other Methods
    func customizationDialog(_ isTaste: Bool, _ arrRemoveCust: [[String:AnyObject]], _ arrCust: [[String:AnyObject]], _ arrTaste: [[String:AnyObject]], _ arrCookingGrades: [[String:AnyObject]]) {
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "CustomizationVC") as? CustomizationVC
            else {
                return
        }
        popupVC.arrFreeCust = arrRemoveCust
        popupVC.arrPaidCust = arrCust
        popupVC.arrTaste = arrTaste
        popupVC.arrCookingGrade = arrCookingGrades
        popupVC.itemID = itemId
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    //MARK:- Webservices
    func callItemDetail() {
        
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
        let serviceURL = Constant.WEBURL + Constant.API.ITEM_DETAILS
        let params = "?time=\(time)&day=\(dayName.lowercased())&user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&item_id=\(itemId)&cart_id=\(cartId)"
        
        //Starting process to fetch the data
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        
                    }else {
                        
                        if let preOrderAccept1 = jsonObject["pre_order_accept"] as? String, preOrderAccept1 != "" {
                            self.preOrderAccept = preOrderAccept1
                            if preOrderAccept1 == "0" {
                                self.btnAdd.isUserInteractionEnabled = false
                                self.vwAdd.BorderColor = UIColor.lightGray
                                self.btnAdd.setTitleColor(UIColor.lightGray, for: .normal)
                            }else {
                                self.btnAdd.isUserInteractionEnabled = true
                                self.vwAdd.BorderColor = AppColors.golden
                                self.btnAdd.setTitleColor(AppColors.golden, for: .normal)
                            }
                        }
                      
                        if let data = jsonObject["responsedata"] as? [String:AnyObject], !data.isEmpty{
                            
                            self.dictData = data
                            
                            if let images = data["images"] as? [String] {
                                self.arrImages = images
                                
                                if images.count > 1 {
                                    self.cnsCvHeight.constant = 120
                                }else {
                                    self.cnsCvHeight.constant = 0
                                }
                            }
                            self.cvImages.reloadData()
                            
                            if let ingre = data["ingredients"] as? String, ingre != "", ingre != "<br>"{
                                self.lblIngredients.text = ingre.html2String
                                self.lblIngredientsTitle.text = Language.INGREDIENTS
                            }else{
                                self.lblIngredientsTitle.text = ""
                            }
                            
                            if let alle = data["allergens"] as? String, alle != "", alle != "<br>"{
                                self.lblAllergens.text = alle.html2String
                                self.lblAllergensTitle.text = Language.ALLERGENS
                            }else {
                                self.lblAllergensTitle.text = ""
                            }
                            
                            if let item_name = data["item_name"] as? String, item_name != ""{
                                self.lblItemName.text = item_name.html2String
                            }  
                            
                            if let isOffered = data["is_offered"] as? String, isOffered == "1" {
                                self.consIvMangal.constant = 20
                                if let price = data["offered_price"] as? String, price != ""{
                                    self.lblPrice.text = "\(self.settingModel.currency ?? "")\(price)"
                                }
                            }else {
                                self.consIvMangal.constant = 0
                                if let price = data["price"] as? String, price != ""{
                                    self.lblPrice.text = "\(self.settingModel.currency ?? "")\(price)"
                                }
                            }
                                                        
                            if let des = data["description"] as? String, des != "", des != "<br>"{
                                self.lblCompanyDesc.text = des.html2String
                                self.lblDescTitle.text = Language.DESCRIPTION
                            }else {
                                self.lblDescTitle.text = ""
                            }
                            
                            if let isbn = data["isbn"] as? String, isbn != ""{
                                self.ivISBN.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                self.ivISBN.sd_setImage(with: URL(string: isbn.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                                    self.ivISBN.sd_imageIndicator = .none
                                }
                                self.consVwISBNHeight.constant = 80
                            }else {
                                self.consVwISBNHeight.constant = 0
                            }
                            
                            if let barcode = data["barcode"] as? String, barcode != ""{
                                self.ivBarCode.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                self.ivBarCode.sd_setImage(with: URL(string: barcode.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                                    self.ivBarCode.sd_imageIndicator = .none
                                }
                                self.consVwBarcodeHeight.constant = 95
                            }else {
                                self.consVwBarcodeHeight.constant = 0
                            }
                            
                            if let url = data["url"] as? String, url != ""{
                                self.lblURL.text = url
                                self.consVwURLHeight.constant = 35
                            }else {
                                self.consVwURLHeight.constant = 0
                            }
                            
                            if let manufacturer = data["manufacturer"] as? String, manufacturer != ""{
                                self.lblManufacturer.text = manufacturer
                                self.consVwManufacturerHeight.constant = 35
                            }else {
                                self.consVwManufacturerHeight.constant = 0
                            }
                            
                            if let publisher = data["publisher"] as? String, publisher != ""{
                                self.lblPublisher.text = publisher
                                self.consVwPublisherHeight.constant = 35
                            }else {
                                self.consVwPublisherHeight.constant = 0
                            }
                            
                            if let size = data["size"] as? String, size != ""{
                                self.lblSize.text = size
                                self.consVwSizeHeight.constant = 35
                            }else {
                                self.consVwSizeHeight.constant = 0
                            }
                            
                            if data["is_show"] as! String == "1" {
                                
                                if let qty = data["quantity"] as? String, qty != "", qty != "0" {
                                    self.lblQty.text = qty
                                    self.consVwQtyHeight.constant = 25
                                    self.consVwAddHeight.constant = 0
                                }else {
                                    self.consVwQtyHeight.constant = 0
                                    self.consVwAddHeight.constant = 25
                                }

                            }else {
                                self.consVwQtyHeight.constant = 0
                                self.consVwAddHeight.constant = 0
                            }
                            
                            if data["item_image"] as! String != ""{
                                self.ivItem.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                self.ivItem.sd_setImage(with: URL(string: (data["item_image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                                    self.ivItem.sd_imageIndicator = .none
                                }
                                self.consItemImageHeight.constant = self.view.frame.size.height * 0.3
                            }else {
                                self.consItemImageHeight.constant = 0.0
                                self.ivItem.image = UIImage(named: "noImage")
                            }
                        }
                        
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callAddToCartAPI(_ paidCust: String, _ freeCust: String, _ taste: String, _ cookingGrade: String) {
        
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
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&restaurant_id=\(self.resId)&item_id=\(itemId)&quantity=1&paid_customization=\(paidCust)&free_customization=\(freeCust)&taste=\(taste)&cooking_grade=\(cookingGrade)&cart_id=\(cartId)&address_id=\(selectedAddressId)&order_type=\(orderType)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
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
                                        self.callAddToCartAPI(paidCust, freeCust, taste, cookingGrade)
                                    }
                                }
                                
                            }else {
                                if let cart_id = responseData["cart_id"] as? String  {
                                    self.settingModel.cart_id = cart_id
                                }
                                
                                if self.comeFrom == "BANNER_ITEM_COMBO" || self.comeFrom == "BANNER_ITEM"{
                                    
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderMenuVC") as! OrderMenuVC
                                    vc.orderType = self.orderType
                                    vc.resId = self.resId
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    
                                }
                                
                                self.callItemDetail()
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
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
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
                            
                            self.callItemDetail()
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
}

extension ItemDetailVC: SelectedCustomizationDelegate {
    
    func selectedCustomization(paidCust: String, freeCust: String, taste: String, cooking_grade: String, itemID: String) {
        if itemID != "" {
            callAddToCartAPI(paidCust, freeCust, taste, cooking_grade)
        }
    }
        
    func refreshItems() {
        self.callItemDetail()
    }
}

extension ItemDetailVC: RemoveItemDelegate {
    func itemRemoved() {
        self.callItemDetail()
    }
    
}

extension ItemDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
                
        cell.ivProduct.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.ivProduct.sd_setImage(with: URL(string: (arrImages[indexPath.row]).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
            cell.ivProduct.sd_imageIndicator = .none
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 100.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.ivItem.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.ivItem.sd_setImage(with: URL(string: (arrImages[indexPath.row]).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
            self.ivItem.sd_imageIndicator = .none
        }
        self.consItemImageHeight.constant = self.view.frame.size.height * 0.3
    }
}
