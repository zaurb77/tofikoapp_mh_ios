//
//  InviteFriendsVC.swift
//  Mangal house
//
//  Created by Mahajan on 08/01/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import FacebookShare
import Social
import Alamofire
import Photos

class InviteFriendsVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var ivLogo: UIImageView!
    
    @IBOutlet weak var vwFacebook: UIView!
    @IBOutlet weak var vwInstagram: UIView!
    @IBOutlet weak var vwLinkedIn: UIView!
    @IBOutlet weak var vwWhatsapp: UIView!
    @IBOutlet weak var vwTelegram: UIView!

    @IBOutlet weak var lblLikeMangal: UILabel!
    @IBOutlet weak var lblInviteMsg: UILabel!
    @IBOutlet weak var lblShareCode: UILabel!
    @IBOutlet weak var lblReferCode: UILabel!
        
    //MARK:- Global Variables
    let documentInteractionController = UIDocumentInteractionController()
    var shareMsg = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        
        lblLikeMangal.text = "\(Language.LIKE_MANGAL)\n\(Language.SHARE_WITH_FRIENDS)"
        lblInviteMsg.text = Language.INVITE_DESCRIPTION
        lblShareCode.text = Language.SHARE_CODE
    }
    
    //MARK:- Other Functions
    func setLayout() {
        if settingModel.facebook_share == "1" {
            vwFacebook.isHidden = false
        }else {
            vwFacebook.isHidden = true
        }
                
        if settingModel.instagram_share == "1" {
            vwInstagram.isHidden = false
        }else {
            vwInstagram.isHidden = true
        }
        
//        if settingModel.linkedin_share == "1" {
//            vwLinkedIn.isHidden = false
//        }else {
//            vwLinkedIn.isHidden = true
//        }
        
        if settingModel.whatsapp_share == "1" {
            vwWhatsapp.isHidden = false
        }else {
            vwWhatsapp.isHidden = true
        }
        
        if settingModel.telegram_share == "1" {
            vwTelegram.isHidden = false
        }else {
            vwTelegram.isHidden = true
        }
        
        if UserModel.sharedInstance().refer_Code != nil && UserModel.sharedInstance().refer_Code != "" {
            lblReferCode.text = UserModel.sharedInstance().refer_Code!
            
            let ref = "\(lblReferCode.text!)"
            let msg = settingModel.referral_msg!
            
            shareMsg = "\(msg)\nReferral Code :- \(ref)\nThank you."
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnFacebook_Action(_ sender: Any) {
               
        let isInstalled = UIApplication.shared.canOpenURL(URL(string: "fb://")!)
        if isInstalled{
                        
            let shareLinkContent = ShareLinkContent()
            shareLinkContent.contentURL = URL(string: "http://www.mangal.house/")!
            shareLinkContent.quote = shareMsg
            
            let shareDialog = ShareDialog()
            shareDialog.shareContent = shareLinkContent
            shareDialog.fromViewController = self
            shareDialog.mode = .automatic
            shareDialog.delegate = self
            shareDialog.show()
        }else {
            self.showWarning(Language.FACEBOOK_INSTALL)
        }
    }
    
    @IBAction func btnInstagram_Action(_ sender: Any) {
        guard let instagramUrl = URL(string: "instagram-stories://share") else {
            return
        }

        if UIApplication.shared.canOpenURL(instagramUrl) {
            if let url = URL(string: self.settingModel.insta_img) {
                do{
                    let data = try Data(contentsOf: url)
                    let pasterboardItems = [["com.instagram.sharedSticker.backgroundImage": UIImage(data: data) as Any]]
                    UIPasteboard.general.setItems(pasterboardItems)
                    UIApplication.shared.open(instagramUrl)
                    UIApplication.shared.open(instagramUrl, options: [:]) { (finish) in
                        if finish {
                            self.callSharePoints("insta")
                        }
                    }
                }catch {}
            }
        } else {
            self.showWarning(Language.INSTALL_INSTA_APP)
        }
    }
    
    @IBAction func btnLinkedIn_Action(_ sender: Any) {
//        let objectsToShare = [shareMsg] as [Any]
//        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        self.present(activityVC, animated: true) {
//            self.callSharePoints("linkedin")
//        }
    }
    
    @IBAction func btnWhatsapp_Action(_ sender: Any) {
        let url  = URL(string: "whatsapp://send?text=\(shareMsg)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:]) { (success) in
                if success {
                    self.callSharePoints("whatsapp")
                    print("WhatsApp accessed successfully")
                } else {
                    print("Error accessing WhatsApp")
                }
            }
        }
    }
    
    @IBAction func btnTelegram_Action(_ sender: Any) {
        let url  = URL(string: "tg://msg?text=\(shareMsg)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:]) { (success) in
                if success {
                    self.callSharePoints("telegram")
                    print("Telegram accessed successfully")
                } else {
                    print("Error accessing WhatsApp")
                }
            }
        }
    }
    
    //MARK:- Webservices
    func callSharePoints(_ type : String) {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.SHARE_POINTS
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&type=\(type)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of this API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                print(jsonObject)
            }
            
        }) { (error) in
            print(error)
        }
    }
}

extension InviteFriendsVC: SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        self.callSharePoints("fb")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("cancelled")
    }
    
    
}
