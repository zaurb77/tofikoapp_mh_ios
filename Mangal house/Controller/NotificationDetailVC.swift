//
//  NotificationDetailVC.swift
//  Mangal house
//
//  Created by Mahajan on 25/07/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class NotificationDetailVC: Main {
    
    //MARK:- Outlets
    var dictData = [String:AnyObject]()
    
    //MARK:- Global Variables
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStorename: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.lblStorename.text = (dictData["store_name"] as! String).html2String
        self.lblHeading.text = (dictData["heading"] as! String).html2String
        self.lblDescription.text = (dictData["description"] as! String).html2String
        
        self.ivImage.sd_imageIndicator = getSDGrayIndicator()
        if let image = self.dictData["image"] as? String, image != ""{
            self.ivImage.sd_setImage(with: URL(string: image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                self.ivImage.sd_imageIndicator = .none}
        }else{
            self.ivImage.image = UIImage(named: "noImage")
        }
        
        if let cat = dictData["cat"] as? String, cat != ""{
            self.lblDate.text = self.convertDateFormatterDynamic(inputFormatter: "yyyy-MM-dd HH:mm:ss", outputFormatter: "MMM dd, yyyy hh:mm a", date: cat)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Other Methods
    
    
    //MARK:- Webservices
    
    
   
    
}
