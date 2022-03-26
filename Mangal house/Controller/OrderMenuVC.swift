//
//  OrderVC.swift
//  Mangal house
//
//  Created by Mahajan on 24/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit
import SDWebImage

class MenuCategoryCell: UICollectionViewCell{
    @IBOutlet weak var ivCategory: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivSelect: CustomImageView!
    
}

class MenuTblItemCell: UITableViewCell{
    
    @IBOutlet weak var consVwAddWidth: NSLayoutConstraint!
    @IBOutlet weak var consVwAddHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAddItem: UIButton!
    
    @IBOutlet weak var cnsIvSpicyWidth: NSLayoutConstraint!
    @IBOutlet weak var cnsIvVegWidth: NSLayoutConstraint!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var cnsIvProductHeight: NSLayoutConstraint!
    
    @IBOutlet weak var consVwQtyWidth: NSLayoutConstraint!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var consVwQtyHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblCustomizable: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblItemNoAvail: UILabel!
    
    @IBOutlet weak var vwAdd: CustomUIView!
}

class MenuCvItemCell: UICollectionViewCell{
    @IBOutlet weak var consVwAddWidth: NSLayoutConstraint!
    @IBOutlet weak var consVwAddHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAddItem: UIButton!
    
    @IBOutlet weak var cnsIvSpicyWidth: NSLayoutConstraint!
    @IBOutlet weak var cnsIvVegWidth: NSLayoutConstraint!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var ivProduct: UIImageView!
    
    @IBOutlet weak var consVwQtyWidth: NSLayoutConstraint!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var consVwQtyHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblCustomizable: UILabel!
    @IBOutlet weak var consLblSeeMoreWidth: NSLayoutConstraint!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblItemNoAvail: UILabel!
    
    @IBOutlet weak var lblSeeMore: UILabel!
    
    @IBOutlet weak var vwAdd: CustomUIView!
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
    @IBOutlet weak var cnsVwResErrorHeight: NSLayoutConstraint!
    @IBOutlet weak var ivLeftError: CustomImageView!
    @IBOutlet weak var ivRightError: CustomImageView!
        
    @IBOutlet weak var tfSearch: CustomTextField!
    @IBOutlet weak var cnsVwSearchHeight: NSLayoutConstraint!
    
    @IBOutlet var vwCatEmpty: UIView!
    @IBOutlet weak var vwItemEmpty: UIView!
    
    @IBOutlet weak var cnsBtnLayoutWidth: NSLayoutConstraint!
    
    @IBOutlet weak var lblMainErrorDesc: UILabel!
    @IBOutlet weak var lblSubErrorDesc: UILabel!
    
    
    @IBOutlet weak var lblItemMainErrorDesc: UILabel!
    @IBOutlet weak var lblItemSubErrorDesc: UILabel!
    
    @IBOutlet weak var lblNext: UILabel!
    
    
    @IBOutlet weak var cnsVwBottom: NSLayoutConstraint!
    
    //MARK:- Global Variables
    var isLayoutGrid = true
    var orderType = ""
    var resId = ""
    var selectedAddressId = ""
    
    var catID = ""
    var arrCatData = [[String:AnyObject]]()
    var arrMenuData = [[String:AnyObject]]()
    var arrFilteredMenuData = [[String:AnyObject]]()
    var isSearchActive = false
    
    var preOrderAccept = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        lblMainErrorDesc.text = Language.CATEGORY_NOT_FOUND
        lblSubErrorDesc.text = Language.RES_CATEGORY_NOT_AVAILABLE
        lblItemMainErrorDesc.text = Language.CATEGORY_ITEM_NOT_AVAILABLE
        lblItemSubErrorDesc.text = Language.ITEM_NOT_AVAILABLE
        lblNext.text = Language.NEXT
        
        vwCategory.layer.cornerRadius = 10
        vwCategory.layer.shadowColor = UIColor.lightGray.cgColor
        vwCategory.layer.shadowOffset = CGSize(width: -1, height: 1)
        vwCategory.layer.shadowOpacity = 0.7
        vwCategory.layer.shadowRadius = 4.0
        
        tfSearch.placeholder = Language.SEARCH_PRODUCT
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
        
        tblorder.tableFooterView = UIView()
        
        tfSearch.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        callCategoryAPI()
        
        if self.settingModel.grid == "1" {
            btnChangeLayout.setImage(UIImage(named: "list"), for: .normal)
            isLayoutGrid = true
            self.cvOrder.isHidden = false
            self.tblorder.isHidden = true
            
            cnsBtnLayoutWidth.constant = 35
        }else {
            
            cnsBtnLayoutWidth.constant = 0
            isLayoutGrid = false
            self.cvOrder.isHidden = true
            self.tblorder.isHidden = false
        }
    }
        
    //MARK:- Button Actions
    @objc func textFieldDidChange(textField: UITextField) {
        performSearch()
    }
    
    func performSearch() {
        let searchString = tfSearch.text
        
        let resultPredicate = NSPredicate(format: "name contains[c]%@ ", searchString!)
        let dictResult = (self.arrMenuData as NSArray).filtered(using: resultPredicate) as [AnyObject]
        arrFilteredMenuData = dictResult as! [Dictionary<String, AnyObject>]
        
        if(searchString == ""){
            isSearchActive = false
        } else {
            isSearchActive = true
        }
        
        tblorder.reloadData()
        cvOrder.reloadData()
    }
    
    @IBAction func btnCart_Action(_ sender: Any) {
        if isGuestUser() {
            changeGuestToLogin()
        }else {
            self.performSegue(withIdentifier: "toOrderList", sender: nil)
        }
    }
    
    @IBAction func btnNextProcess_Action(_ sender: Any) {
        
        var cnt = 0
        var selectPos = 0
        for i in 0..<arrCatData.count {
            cnt += 1
            if self.arrCatData[i]["id"] as! String == catID && (self.arrCatData.count - 1) >= i + 1 {
                selectPos = i
                catID = self.arrCatData[i + 1]["id"] as! String
                break
            }
        }
        
        if arrCatData.count == cnt {
            if isGuestUser() {
                changeGuestToLogin()
            }else {
                self.performSegue(withIdentifier: "toOrderList", sender: nil)
            }
        }else {
            let nextItem: IndexPath = IndexPath(item: selectPos, section: 0)
            if nextItem.row < arrCatData.count {
                self.cvCategory.scrollToItem(at: nextItem, at: .centeredHorizontally, animated: true)
            }
            self.cvCategory.reloadData()
            
            callItemAPI()
        }
    }
    
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
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
    
    @IBAction func btnPrevious_Action(_ sender: Any) {
//        let visibleItems: NSArray = self.cvCategory.indexPathsForVisibleItems as NSArray
//        let currentItem: IndexPath = visibleItems.lastObject as! IndexPath
//        let prevItem: IndexPath = IndexPath(item: currentItem.item - 1, section: 0)
//        if prevItem.row < arrCatData.count {
//            DispatchQueue.main.async {
//                self.cvCategory.scrollToItem(at: prevItem, at: .centeredHorizontally, animated: true)
//            }
//
//        }
        
        var cnt = 0
        var selectPos = 0
        var curPos = 0
        for i in 0..<arrCatData.count {
            cnt += 1
             
            if self.arrCatData[i]["id"] as! String == catID {
                curPos = i
            }
            
            if self.arrCatData[i]["id"] as! String == catID && i != 0 && (self.arrCatData.count - 1) >= i - 1 {
                selectPos = i
                catID = self.arrCatData[i - 1]["id"] as! String
                break
            }
        }
        
        if curPos != 0 {
            if arrCatData.count == cnt {
//                if isGuestUser() {
//                    changeGuestToLogin()
//                }else {
//                    self.performSegue(withIdentifier: "toOrderList", sender: nil)
//                }
            }else {
                let prevItem: IndexPath = IndexPath(item: selectPos, section: 0)
                if prevItem.row < arrCatData.count {
                    self.cvCategory.scrollToItem(at: prevItem, at: .centeredHorizontally, animated: true)
                }
                self.cvCategory.reloadData()
                
                callItemAPI()
            }
        }
    }
    
    @IBAction func btnNext_Action(_ sender: Any) {
//        let visibleItems: NSArray = self.cvCategory.indexPathsForVisibleItems as NSArray
//        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
//        let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
//        if nextItem.row < arrCatData.count {
//            DispatchQueue.main.async {
//                self.cvCategory.scrollToItem(at: nextItem, at: .centeredHorizontally, animated: true)
//            }
//
//        }
        
        var cnt = 0
        var selectPos = 0
        for i in 0..<arrCatData.count {
            cnt += 1
            if self.arrCatData[i]["id"] as! String == catID && (self.arrCatData.count - 1) >= i + 1 {
                selectPos = i
                catID = self.arrCatData[i + 1]["id"] as! String
                break
            }
        }
        
        if arrCatData.count == cnt {
//            if isGuestUser() {
//                changeGuestToLogin()
//            }else {
//                self.performSegue(withIdentifier: "toOrderList", sender: nil)
//            }
        }else {
            let nextItem: IndexPath = IndexPath(item: selectPos, section: 0)
            if nextItem.row < arrCatData.count {
                self.cvCategory.scrollToItem(at: nextItem, at: .centeredHorizontally, animated: true)
            }
            self.cvCategory.reloadData()
            
            callItemAPI()
        }
    }
    
    @objc func btnAddItem_Action(_ sender: UIButton) {
        
        if isGuestUser() {
            changeGuestToLogin()
        }else {
            var dictData = [String: AnyObject]()
            if isSearchActive {
                dictData = arrFilteredMenuData[sender.tag]
            }else {
                dictData = arrMenuData[sender.tag]
            }
            
            let arrRemoveCust = dictData["remove_customization"] as! [[String:AnyObject]]
            let arrCust = dictData["customization"] as! [[String:AnyObject]]
            let arrTaste = dictData["taste"] as! [[String:AnyObject]]
            let arrCookingGrade = dictData["cooking_grades"] as! [[String:AnyObject]]
            
            if arrRemoveCust.count == 0 && arrCust.count == 0 && arrTaste.count == 0  && arrCookingGrade.count == 0 {
                callAddToCartAPI("", "", "", "", dictData["id"] as! String)
                
            }else {
                customizationDialog(dictData["id"] as! String, arrRemoveCust, arrCust, arrTaste, arrCookingGrade)
            }
        }
    }
    
    @objc func btnPlus_Action(_ sender: UIButton) {
        
        var dictData = [String: AnyObject]()
        if isSearchActive {
            dictData = arrFilteredMenuData[sender.tag]
        }else {
            dictData = arrMenuData[sender.tag]
        }
        
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
            customizationDialog(dictData["id"] as! String, arrRemoveCust, arrCust, arrTaste, arrCookingGrade)
        }
    }
       
    @objc func btnMinus_Action(_ sender: UIButton) {
        var dictData = [String: AnyObject]()
        if isSearchActive {
            dictData = arrFilteredMenuData[sender.tag]
        }else {
            dictData = arrMenuData[sender.tag]
        }
        
        let arrCartItems = dictData["cart_items"] as! [[String:AnyObject]]
        
        if arrCartItems.count > 1 {
            
            guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "RemoveCartItemVC") as? RemoveCartItemVC
                else {
                    return
            }
            popupVC.delegate = self
            popupVC.itemID = dictData["id"] as! String
            present(popupVC, animated: true, completion: nil)
            
        }else {
            var qty = 0
            if dictData["quantity"] as! String != "" && dictData["quantity"] as! String != "0" {
                qty = Int(dictData["quantity"] as! String)!
            }
            callChangeQtyAPI(dictData["cart_item_id"] as! String, "\(qty - 1)")
        }
    }
    
    //MARK:- Other Functions
    func callAPI() {
        if catID != "" {
            callItemAPI()
        }else {
            callCategoryAPI()
        }
    }
    
    func customizationDialog(_ id: String, _ arrRemoveCust: [[String:AnyObject]], _ arrCust: [[String:AnyObject]], _ arrTaste: [[String:AnyObject]], _ arrCookingGrade: [[String:AnyObject]]) {
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "CustomizationVC") as? CustomizationVC
            else {
                return
        }
        popupVC.arrFreeCust = arrRemoveCust
        popupVC.arrPaidCust = arrCust
        popupVC.arrTaste = arrTaste
        popupVC.arrCookingGrade = arrCookingGrade
        popupVC.itemID = id
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    //MARK:- Web Service Calling
    func callGetSettingAPI(_ paidCust: String, _ freeCust: String, _ taste: String, _ cooking_grade: String, _ itemID: String) {
        
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
        let serviceURL = Constant.WEBURL + Constant.API.GET_APP_SETTINGS
        let params = "?latitude=\(LocationManager.sharedInstance.latitude)&longitude=\(LocationManager.sharedInstance.longitude)&user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&cart_id=\(cartId)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
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
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                                                        
                            if responseData["order_status"] as! String == "1" {
                                self.settingModel.cart_id = responseData["cart_id"] as? String
                            }else {
                                self.settingModel.cart_id = ""
                                self.settingModel.selected_delivery_address = ""
                            }
                            
                            self.callAddToCartAPI(paidCust, freeCust, taste, cooking_grade, itemID)
                            
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
    
    func callCategoryAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: Date())
        
        df.dateFormat = "EEEE"
        let dayName = df.string(from: Date())
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.RESTAURANT_CATEGORY
        let params = "?time=\(time)&day=\(dayName.lowercased())&restaurant_id=\(self.resId)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        
                        self.vwCatEmpty.isHidden = false
                        
                    }else {
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]], responseData.count > 0 {
                            self.arrCatData = responseData
                            self.vwCategory.isHidden = false
                        }
                        
                        if self.arrCatData.count > 0 {
                            self.vwCatEmpty.isHidden = true
                            if self.catID == "" {
                                self.catID = self.arrCatData[0]["id"] as! String
                            }
                            self.callItemAPI()
                        }else {
                            self.vwCatEmpty.isHidden = false
                        }
                        
                        if let resError = jsonObject["res_open_error"] as? String, resError != "" {
                            self.lblResError.text = resError
                            self.cnsVwResErrorHeight.constant = 40
                            
                            if let preOrderAccept = jsonObject["pre_order_accept"] as? String, preOrderAccept != "" {
                                if preOrderAccept == "1" {
                                    self.ivLeftError.backgroundColor = UIColor(red: 64/255, green: 173/255, blue: 48/255, alpha: 1.0)
                                    self.ivRightError.backgroundColor = UIColor(red: 64/255, green: 173/255, blue: 48/255, alpha: 1.0)
                                }else if preOrderAccept == "0" {
                                    self.ivLeftError.backgroundColor = UIColor(red: 176/255, green: 51/255, blue: 63/255, alpha: 1.0)
                                    self.ivRightError.backgroundColor = UIColor(red: 176/255, green: 51/255, blue: 63/255, alpha: 1.0)
                                }
                                self.preOrderAccept = preOrderAccept
                            }

                        }else {
                            self.preOrderAccept = ""
                            self.lblResError.text = ""
                            self.cnsVwResErrorHeight.constant = 0
                        }
                        
                        self.cvCategory.reloadData()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callItemAPI() {
        
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
        
        var userId = "", authToken = ""
        if isGuestUser() {
            userId = ""
            authToken = ""
        }else {
            userId =  UserModel.sharedInstance().user_id!
            authToken = UserModel.sharedInstance().authToken!
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.RESTAURANT_MENU_ITEMS
        let params = "?user_id=\(userId)&auth_token=\(authToken)&restaurant_id=\(self.resId)&cat_id=\(catID)&cart_id=\(cartId)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        
                        self.vwItemEmpty.isHidden = false
                        self.cvOrder.isHidden = true
                        self.tblorder.isHidden = true
                                                
                    }else {
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]] {
                            self.arrMenuData = responseData
                        }
                        
                        if let cartItems = jsonObject["cart_items"] as? String, cartItems != "" {
                            self.lblQty.text = "\(cartItems)"
                            self.lblQty.isHidden = false
                        }else {
                            self.lblQty.text = ""
                            self.lblQty.isHidden = true
                        }
                        
                        if let finalTotal = jsonObject["final_total"] as? String, finalTotal != "0.00" {
                            self.lblTotal.text = "\(Language.TOTAL) | \(self.settingModel.currency ?? "")\(finalTotal)"
                        }else {
                            self.lblTotal.text = ""
                        }
                        
                        if self.arrMenuData.count > 0 {
                            self.vwItemEmpty.isHidden = true
                            self.cnsVwBottom.constant = 50
                            if self.isLayoutGrid{
                                self.cvOrder.isHidden = false
                                self.tblorder.isHidden = true
                            }else{
                                self.cvOrder.isHidden = true
                                self.tblorder.isHidden = false
                            }
                        }else {
                            self.cnsVwBottom.constant = 0
                            self.vwItemEmpty.isHidden = false
                            self.cvOrder.isHidden = true
                            self.tblorder.isHidden = true
                        }
                        
                        self.performSearch()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callAddToCartAPI(_ paidCust: String, _ freeCust: String, _ taste: String,  _ cookingGrade: String, _ itemID: String) {
        
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
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&restaurant_id=\(self.resId)&item_id=\(itemID)&quantity=1&paid_customization=\(paidCust)&taste=\(taste)&free_customization=\(freeCust)&cooking_grade=\(cookingGrade)&cart_id=\(cartId)&address_id=\(selectedAddressId)&order_type=\(orderType)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.callGetSettingAPI(paidCust, freeCust, taste, cookingGrade, itemID)
                        
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
                                        self.callAddToCartAPI(paidCust, freeCust, taste, cookingGrade, itemID)
                                    }
                                }
                                
                            }else {
                                if let cart_id = responseData["cart_id"] as? String  {
                                    self.settingModel.cart_id = cart_id
                                }
                                self.callItemAPI()
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
                            
                            self.callItemAPI()
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
}

extension OrderMenuVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvCategory {
            return arrCatData.count
        }else{
            
            if isSearchActive {
                return arrFilteredMenuData.count
            }else {
                return arrMenuData.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == cvCategory {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCategoryCell", for: indexPath) as! MenuCategoryCell
            
            cell.ivCategory.sd_imageIndicator = getSDGrayIndicator()
            if let image = (self.arrCatData[indexPath.row])["image"] as? String, image != ""{
                cell.ivCategory.sd_setImage(with: URL(string: image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                    cell.ivCategory.sd_imageIndicator = .none}
            }else{
                cell.ivCategory.image = UIImage(named: "noImage")
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
            
            var dictData = [String: AnyObject]()
            if isSearchActive {
                dictData = arrFilteredMenuData[indexPath.row]
            }else {
                dictData = arrMenuData[indexPath.row]
            }
                        
            if dictData["image_enable"] as! String == "1" && dictData["image"] as! String != ""{
                cell.ivProduct.sd_imageIndicator = getSDGrayIndicator()
                cell.ivProduct.sd_setImage(with: URL(string: (dictData["image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                    cell.ivProduct.sd_imageIndicator = .none
                }
            }else {
                cell.ivProduct.image = UIImage(named: "noImage")
            }
            
            cell.lblName.text = dictData["name"] as? String
            if let price = dictData["price"] as? String, price != ""{
                cell.lblPrice.text = "\(self.settingModel.currency ?? "")\(price)"
            }else{
                cell.lblPrice.text = ""
            }
            
            if let ingredients = dictData["ingredients"] as? String, ingredients != "" {
                cell.lblDesc.text = ingredients.html2String
                cell.consLblSeeMoreWidth.constant = 55
            }else {
                cell.lblDesc.text = ""
                cell.consLblSeeMoreWidth.constant = 0
            }
            
            if dictData["is_spicy"] as! String == "1" {
                cell.cnsIvSpicyWidth.constant = 15
            }else {
                cell.cnsIvSpicyWidth.constant = 0
            }
            
            if dictData["is_veg"] as! String == "1" {
                cell.cnsIvVegWidth.constant = 15
            }else {
                cell.cnsIvVegWidth.constant = 0
            }
            
            if dictData["is_show"] as! String == "1" {
                
                cell.consVwQtyHeight.constant = 25
                cell.consVwAddHeight.constant = 25
                
                cell.consVwAddWidth.constant = 70
                cell.lblItemNoAvail.text = ""

                if let qty = dictData["quantity"] as? String, qty != "", qty != "0" {

                    cell.lblQty.text = qty

                    cell.consVwQtyWidth.constant = 70
                    cell.consVwAddWidth.constant = 0
                    
                }else {
                    cell.consVwQtyWidth.constant = 0
                }

            }else {
                cell.consVwQtyHeight.constant = 0
                cell.consVwAddHeight.constant = 0
                cell.lblItemNoAvail.text = Language.NO_ITEM_ERROR
            }
            
            let removeCust = dictData["remove_customization"] as! [[String:AnyObject]]
            let cust = dictData["customization"] as! [[String:AnyObject]]
            
            if removeCust.count > 0 || cust.count > 0 {
                cell.lblCustomizable.text = Language.CUSTOMIZABLE
                if dictData["is_show"] as! String == "1" {
                    cell.lblCustomizable.text = Language.CUSTOMIZABLE
                }else {
                    cell.lblCustomizable.text = ""
                }
            }else {
                cell.lblCustomizable.text = ""
            }
                  
            cell.lblSeeMore.text = Language.SEE_MORE
            
            if self.preOrderAccept == "0" {
                cell.btnAddItem.isUserInteractionEnabled = false
                cell.vwAdd.BorderColor = UIColor.lightGray
                cell.btnAddItem.setTitleColor(UIColor.lightGray, for: .normal)
            }else {
                cell.btnAddItem.isUserInteractionEnabled = true
                cell.vwAdd.BorderColor = AppColors.golden
                cell.btnAddItem.setTitleColor(AppColors.golden, for: .normal)
            }
            
            cell.btnAddItem.setTitle(Language.ADD, for: .normal)
            cell.btnAddItem.tag = indexPath.row
            cell.btnAddItem.addTarget(self, action: #selector(btnAddItem_Action(_:)), for: .touchUpInside)
            
            cell.btnPlus.tag = indexPath.row
            cell.btnPlus.addTarget(self, action: #selector(btnPlus_Action(_:)), for: .touchUpInside)
            
            cell.btnMinus.tag = indexPath.row
            cell.btnMinus.addTarget(self, action: #selector(btnMinus_Action(_:)), for: .touchUpInside)
                        
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvCategory {
            catID = self.arrCatData[indexPath.row]["id"] as! String
            cvCategory.reloadData()
            callItemAPI()
        }else{
            
            if isGuestUser() {
                changeGuestToLogin()
            }else {
                //if self.preOrderAccept != "0" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailVC") as! ItemDetailVC
                    vc.orderType = self.orderType
                    
                    if isSearchActive {
                        vc.itemId = self.arrFilteredMenuData[indexPath.row]["id"] as! String
                    }else {
                        vc.itemId = self.arrMenuData[indexPath.row]["id"] as! String
                    }
                    
                    vc.resId = self.resId
                    vc.selectedAddressId = self.selectedAddressId
                    self.navigationController?.pushViewController(vc, animated: true)
                //}
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvCategory{
            return CGSize(width: collectionView.frame.width / 4, height: 80)
        }else{
            let size = self.cvOrder.frame.size.width
            return CGSize(width: ((size - 20) / 2), height: (size / 2) + 20 )
        }
        
        //(self.cvOffers.frame.size.width - 20) / 2, height: 190)
    }
}

extension OrderMenuVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return arrFilteredMenuData.count
        }else {
            return arrMenuData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTblItemCell") as! MenuTblItemCell
        
        var dictData = [String:AnyObject]()
        if isSearchActive {
            dictData = arrFilteredMenuData[indexPath.row]
        }else {
            dictData = arrMenuData[indexPath.row]
        }
        
        if dictData["image_enable"] as! String == "1" {
            cell.cnsIvProductHeight.constant = 80
            if dictData["image"] as! String != ""{
                cell.ivProduct.sd_imageIndicator = getSDGrayIndicator()
                cell.ivProduct.sd_setImage(with: URL(string: (dictData["image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                    cell.ivProduct.sd_imageIndicator = .none
                }
            }else {
                cell.cnsIvProductHeight.constant = 0
            }
        }else {
            cell.cnsIvProductHeight.constant = 0
        }
        
        cell.lblName.text = dictData["name"] as? String
        if let price = dictData["price"] as? String, price != ""{
            cell.lblPrice.text = "\(self.settingModel.currency ?? "")\(price)"
        }else{
            cell.lblPrice.text = ""
        }
        if let ingredients = dictData["ingredients"] as? String, ingredients != "" {
            cell.lblDesc.text = ingredients.html2String
        }else {
            cell.lblDesc.text = ""
        }
        
        if dictData["is_spicy"] as! String == "1" {
            cell.cnsIvSpicyWidth.constant = 15
        }else {
            cell.cnsIvSpicyWidth.constant = 0
        }
        
        if dictData["is_veg"] as! String == "1" {
            cell.cnsIvVegWidth.constant = 15
        }else {
            cell.cnsIvVegWidth.constant = 0
        }
        
        cell.consVwQtyHeight.constant = 25
        cell.consVwAddHeight.constant = 25
        self.view.layoutIfNeeded()
        
//        DispatchQueue.main.async {
            if dictData["is_show"] as! String == "1" {
                
                cell.consVwQtyHeight.constant = 25
                cell.consVwAddHeight.constant = 25
                
                cell.lblItemNoAvail.text = ""

                if let qty = dictData["quantity"] as? String, qty != "", qty != "0" {
                    cell.lblQty.text = qty
                    cell.consVwQtyHeight.constant = 25
                    cell.consVwAddHeight.constant = 0
                }else {
                    cell.consVwQtyHeight.constant = 0
                    cell.consVwAddHeight.constant = 25
                }

            }else {
                cell.consVwAddHeight.constant = 0
                cell.consVwQtyHeight.constant = 0
                cell.lblItemNoAvail.text = Language.NO_ITEM_ERROR
            }
//        }
        
        
        let removeCust = dictData["remove_customization"] as! [[String:AnyObject]]
        let cust = dictData["customization"] as! [[String:AnyObject]]
        
        if removeCust.count > 0 || cust.count > 0 {
            cell.lblCustomizable.text = Language.CUSTOMIZABLE
            if dictData["is_show"] as! String == "1" {
                cell.lblCustomizable.text = Language.CUSTOMIZABLE
            }else {
                cell.lblCustomizable.text = ""
            }
        }else {
            cell.lblCustomizable.text = ""
        }
             
        if self.preOrderAccept == "0" {
            cell.btnAddItem.isUserInteractionEnabled = false
            cell.vwAdd.BorderColor = UIColor.lightGray
            cell.btnAddItem.setTitleColor(UIColor.lightGray, for: .normal)
        }else {
            cell.btnAddItem.isUserInteractionEnabled = true
            cell.vwAdd.BorderColor = AppColors.golden
            cell.btnAddItem.setTitleColor(AppColors.golden, for: .normal)
        }
        
        cell.btnAddItem.setTitle(Language.ADD, for: .normal)
        cell.btnAddItem.tag = indexPath.row
        cell.btnAddItem.addTarget(self, action: #selector(btnAddItem_Action(_:)), for: .touchUpInside)
        
        cell.btnPlus.tag = indexPath.row
        cell.btnPlus.addTarget(self, action: #selector(btnPlus_Action(_:)), for: .touchUpInside)
        
        cell.btnMinus.tag = indexPath.row
        cell.btnMinus.addTarget(self, action: #selector(btnMinus_Action(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isGuestUser() {
            changeGuestToLogin()
        }else {
            
            //if self.preOrderAccept != "0" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailVC") as! ItemDetailVC
                vc.orderType = self.orderType
                
                if isSearchActive {
                    vc.itemId = self.arrFilteredMenuData[indexPath.row]["id"] as! String
                }else {
                    vc.itemId = self.arrMenuData[indexPath.row]["id"] as! String
                }
                
                vc.resId = self.resId
                vc.selectedAddressId = self.selectedAddressId
                self.navigationController?.pushViewController(vc, animated: true)
            //}
        }
    }
}

extension OrderMenuVC: SelectedCustomizationDelegate {
    
    func selectedCustomization(paidCust: String, freeCust: String, taste: String, cooking_grade: String, itemID: String) {
        if isGuestUser() {
            changeGuestToLogin()
        }else {
            if itemID != "" {
                callAddToCartAPI(paidCust, freeCust, taste, cooking_grade, itemID)
            }
        }
        //call taste here
    }
    
    func refreshItems() {
        if isGuestUser() {
            changeGuestToLogin()
        }else {
            self.callItemAPI()
        }
    }
}

extension OrderMenuVC: RemoveItemDelegate {
    func itemRemoved() {
        if isGuestUser() {
            changeGuestToLogin()
        }else {
            self.callItemAPI()
        }
    }
}


