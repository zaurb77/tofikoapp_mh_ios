//
//  CustomizationVC.swift
//  Mangal house
//
//  Created by Mahajan on 28/01/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import BottomPopup

protocol SelectedCustomizationDelegate : NSObjectProtocol{
    func selectedCustomization(paidCust: String, freeCust: String, taste: String, cooking_grade: String, itemID: String)
    func refreshItems()
}

class ItemCustomizationCell : UITableViewCell {
    @IBOutlet var lblAddOn: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet weak var btnCustomize: UIButton!
}

class CustomizationVC: BottomPopupViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnApplyChanges: UIButton!
    
    //MARK:- Global Variables
    weak var delegate : SelectedCustomizationDelegate?

    var pHeight = 500.0
    var isFromTest = false
    var arrFreeCust = [[String:AnyObject]]()
    var arrPaidCust = [[String:AnyObject]]()
    var arrTaste = [[String:AnyObject]]()
    var arrCookingGrade = [[String:AnyObject]]()
    
    var paidCustomization = "", freeCustomization = "", selectedTaste = "", selectedGrade = "", itemID = ""
    var selectedPos = -1
    var selectedGradePos = -1
    
    //MARK:- Overridden Variables
    override var popupHeight: CGFloat {
        return CGFloat(pHeight)
    }
    override var popupTopCornerRadius: CGFloat { return  CGFloat(20) }
    override var popupPresentDuration: Double { return  0.5 }
    override var popupDismissDuration: Double { return  0.5 }
    override var popupShouldDismissInteractivelty: Bool { return  true }
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        
        for i in 0..<arrTaste.count {
            if arrTaste[i]["is_default"] as! String == "1" {
                selectedPos = i
                break
            }
        }
        
        for i in 0..<arrCookingGrade.count {
            if arrCookingGrade[i]["is_default"] as! String == "1" {
                selectedGradePos = i
                break
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isBeingDismissed {
            self.dismiss(animated: true) {
                self.delegate?.refreshItems()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isFromTest {
            lblTitle.text = Language.CHOOSE_TEST.uppercased()
        }else {
            lblTitle.text = Language.ITEM_CUSTOMIZATION.uppercased()
        }
        lblTitle.text = ""
        
        btnApplyChanges.setTitle(Language.APPLY_CHANGES.uppercased(), for: .normal)
        
        for i in 0..<arrPaidCust.count {
            arrPaidCust[i]["selected"] = 0 as AnyObject
        }
        
        for i in 0..<arrFreeCust.count {
            arrFreeCust[i]["selected"] = 0 as AnyObject
        }
                
        self.tblView.reloadData()
        let contentHeight = Double(self.tblView.contentSize.height + 170.0)
        if contentHeight < 500.0 {
            self.pHeight = contentHeight
            self.tblView.isScrollEnabled = false
        }else {
            self.pHeight = 500.0
            self.tblView.isScrollEnabled = true
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnClose_Action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnApplyChanges_Action(_ sender: Any) {
        
        let arrSelectedPaid = arrPaidCust.filter{$0["selected"] as! Int == 1}
        let arrSelectedFree = arrFreeCust.filter{$0["selected"] as! Int == 1}
        
        var arrTemp = [String](), arrFree = [String]()
        if arrSelectedPaid.count > 0 {
            for i in 0..<arrSelectedPaid.count {
                arrTemp.append("\(arrSelectedPaid[i]["name"] as! String)=\(arrSelectedPaid[i]["price"] as! String)")
            }
        }
        
        if arrSelectedFree.count > 0 {
            for i in 0..<arrSelectedFree.count {
                arrFree.append(arrSelectedFree[i]["name"] as! String)
            }
        }
        
        if selectedPos != -1 {
            selectedTaste = arrTaste[selectedPos]["name"] as! String
        }
        
        if selectedGradePos != -1 {
            selectedGrade = arrCookingGrade[selectedGradePos]["name"] as! String
        }
        
        delegate?.selectedCustomization(paidCust: arrTemp.joined(separator: ","), freeCust: arrFree.joined(separator: ","), taste: selectedTaste, cooking_grade: selectedGrade, itemID: itemID)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func btnSkip_Action(_ sender: Any) {
        paidCustomization = ""
        freeCustomization = ""
        selectedTaste = ""
        selectedGrade = ""
        delegate?.selectedCustomization(paidCust: "", freeCust: "", taste: selectedTaste, cooking_grade: selectedGrade, itemID: itemID)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func btnCustomize_Action(_ sender: UIButton) {
        
    }
    
}

extension CustomizationVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //It will show first Taste, then Addons, then remove
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return arrTaste.count
            
        }else if section == 1 {
            return arrCookingGrade.count
            
        }else if section == 2 {
            return arrPaidCust.count
            
        }else {
            return arrFreeCust.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCustomizationCell", for: indexPath) as! ItemCustomizationCell
                
        if indexPath.section == 0 {
            cell.lblAddOn.text = (arrTaste[indexPath.row]["name"] as! String).html2String
            cell.lblPrice.text = ""
            
            if indexPath.row == selectedPos {
                cell.btnCustomize.setImage(UIImage(named: "radioOn"), for: .normal)
            }else {
                cell.btnCustomize.setImage(UIImage(named: "radioOff"), for: .normal)
            }
            
        }else if indexPath.section == 1 {
            cell.lblAddOn.text = (arrCookingGrade[indexPath.row]["name"] as! String).html2String
            cell.lblPrice.text = ""
            
            if indexPath.row == selectedGradePos {
                cell.btnCustomize.setImage(UIImage(named: "radioOn"), for: .normal)
            }else {
                cell.btnCustomize.setImage(UIImage(named: "radioOff"), for: .normal)
            }
            
        }else if indexPath.section == 2 {
            cell.lblAddOn.text = (arrPaidCust[indexPath.row]["name"] as! String).html2String
            
            if arrPaidCust[indexPath.row]["selected"] as! Int == 0 {
                cell.btnCustomize.setImage(UIImage(named: "checkboxEmpty"), for: .normal)
            }else {
                cell.btnCustomize.setImage(UIImage(named: "checkboxFill"), for: .normal)
            }
            
            if let price = (arrPaidCust[indexPath.row])["price"] as? String, price != ""{
                cell.lblPrice.text = "\(SettingsModels.shared.currency ?? "")\(price)"
            }else{
                cell.lblPrice.text = ""
            }
            
        }else {
            cell.lblAddOn.text = (arrFreeCust[indexPath.row]["name"] as! String).html2String
            cell.lblPrice.text = ""
            
            if arrFreeCust[indexPath.row]["selected"] as! Int == 0 {
                cell.btnCustomize.setImage(UIImage(named: "checkboxEmpty"), for: .normal)
            }else {
                cell.btnCustomize.setImage(UIImage(named: "checkboxFill"), for: .normal)
            }
        }
        
//        cell.btnCustomize.tag = indexPath.row
//        cell.btnCustomize.accessibilityIdentifier = "\(ind?exPath.section)"
//        cell.btnCustomize.addTarget(self, action: #selector(btnCustomize_Action), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if section == 0 {
            selectedPos = indexPath.row
            
        }else if section == 1 {
            selectedGradePos = indexPath.row
            
        }else if section == 2 {
            
            if arrPaidCust[indexPath.row]["selected"] as! Int == 0 {
                arrPaidCust[indexPath.row]["selected"] = 1 as AnyObject
            }else {
                arrPaidCust[indexPath.row]["selected"] = 0 as AnyObject
            }
            
        }else {
            if arrFreeCust[indexPath.row]["selected"] as! Int == 0 {
                arrFreeCust[indexPath.row]["selected"] = 1 as AnyObject
            }else {
                arrFreeCust[indexPath.row]["selected"] = 0 as AnyObject
            }
            
        }
        self.tblView.reloadData()
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vwHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 20.0, height: 30.0))
        vwHeader.backgroundColor = .white
        
        let lblHeaderTitle = UILabel(frame: CGRect(x: 15, y: 5, width: self.view.frame.width - 50.0, height: 25.0))
        lblHeaderTitle.font = UIFont(name: "Raleway-Bold", size: 18.0)
        lblHeaderTitle.textColor = AppColors.golden
        vwHeader.addSubview(lblHeaderTitle)
        
        if section == 0 && arrTaste.count > 0 {
            lblHeaderTitle.text = Language.CHOOSE_TEST
            return vwHeader
            
        }else if section == 1 && arrCookingGrade.count > 0 {
            lblHeaderTitle.text = Language.COOKING_LEVEL
            return vwHeader
            
        }else if section == 2 && arrPaidCust.count > 0 {
            lblHeaderTitle.text = Language.ADD_EXTRA
            return vwHeader
            
        }else if section == 3 && arrFreeCust.count > 0 {
            lblHeaderTitle.text = Language.WANT_TO_REMOVE
            return vwHeader
        }else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && arrTaste.count > 0 {
            return 30
        }else if section == 1 && arrCookingGrade.count > 0 {
            return 30
        }else if section == 2 && arrPaidCust.count > 0 {
            return 30
        }else if section == 3 && arrFreeCust.count > 0 {
            return 30
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
