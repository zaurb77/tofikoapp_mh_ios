//
//  APIManager.swift
//  Mangal House
//
//  Created by APPLE on 07/10/19.
//  Copyright © 2019 Mahajan-iOS. All rights reserved.
//

import Foundation
import Alamofire

class APIManager : NSObject {
    
    static let shared = APIManager()
    
    func requestGETURL(_ strURL: String, success:@escaping (DataResponse<Any>) -> Void, failure:@escaping (Error) -> Void) {
        CommonFunctions.shared.showLoader()
        
        print("Service URL is : \(strURL)")
        
        Alamofire.request(URL(string: strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON{ (response: DataResponse<Any>) in
            switch response.result {
                case .success(_):
                    print("Success")
                    CommonFunctions.shared.hideLoader()
                    success(response)
                
                case .failure(let error):
                    debugPrint(error)
                    CommonFunctions.shared.hideLoader()
                    failure(error)
            }
        }
    }
    
    func requestGETURLNoLoader(_ strURL: String, success:@escaping (DataResponse<Any>) -> Void, failure:@escaping (Error) -> Void) {
        
        print("Service URL is : \(strURL)")
        
        Alamofire.request(URL(string: strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON{ (response: DataResponse<Any>) in
            switch response.result {
                case .success(_):
                    print("Success")
                    success(response)
                
                case .failure(let error):
                    debugPrint(error)
                    failure(error)
            }
        }
    }
    
    func requestPostURL(_ strURL: String,param:[String:String], success:@escaping (DataResponse<Any>) -> Void, failure:@escaping (Error) -> Void) {
        
        CommonFunctions.shared.showLoader()
        
        print("Service URL is : \(strURL)")

        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, to: strURL) { (result) in
             
            switch result {
                case .success(let upload, _, _):
                    
                     
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                        //CommonFunctions.shared.showLoader(Float(progress.fractionCompleted))
                    })
                    
                    upload.responseJSON { response in
                        CommonFunctions.shared.hideLoader()
                        if response.response?.statusCode == 200 {
                            success(response)
                            
                        }else {
                            failure(response.result.error!)
                        }
                    }
                case .failure(let encodingError):
                    CommonFunctions.shared.hideLoader()
                    failure(encodingError)
            }
        }
    }
    
    func requestNoLoaderPostURL(_ strURL: String,param:[String:String], success:@escaping (DataResponse<Any>) -> Void, failure:@escaping (Error) -> Void) {
        print("Service URL is : \(strURL)")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: strURL) { (result) in
            switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        if response.response?.statusCode == 200 {
                            success(response)
                        }else {
                            failure(response.result.error!)
                        }
                    }
                case .failure(let encodingError):
                    failure(encodingError)
            }
        }
    }
    
    func requestImageUpload(_ strURL: String, _ params:[String:String], _ image:UIImage, success:@escaping (DataResponse<Any>) -> Void, failure:@escaping (Error) -> Void) {
        
        CommonFunctions.shared.showLoader()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            let imgData = image.jpegData(compressionQuality: 0.8)
            multipartFormData.append(imgData!, withName: "image",fileName: "image.png", mimeType: "image/png")
            
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, to: strURL) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    CommonFunctions.shared.showLoader(Float(progress.fractionCompleted))
                })
                upload.responseJSON { response in
                    CommonFunctions.shared.hideLoader()
                    if response.response?.statusCode == 200 {
                        success(response)
                    }else {
                        failure(response.result.error!)
                    }
                }
            case .failure(let encodingError):
                CommonFunctions.shared.hideLoader()
                failure(encodingError)
            }
        }
    }
    
    func requestMultipleImageUpload(_ strURL: String, _ params:[String:String], _ image: [UIImage], success:@escaping (DataResponse<Any>) -> Void, failure:@escaping (Error) -> Void) {
        
        CommonFunctions.shared.showLoader()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if image.count > 0{
                for i in 0..<image.count{
                    let imgData = image[i].jpegData(compressionQuality: 1.0)
                    multipartFormData.append(imgData!, withName: "image_\(i+1)",fileName: "image.png", mimeType: "image/png")
                }
            }
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, to: strURL) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    CommonFunctions.shared.showLoader(Float(progress.fractionCompleted))
                })
                upload.responseJSON { response in
                    CommonFunctions.shared.hideLoader()
                    if response.response?.statusCode == 200 {
                        success(response)
                    }else {
                        failure(response.result.error!)
                    }
                }
            case .failure(let encodingError):
                CommonFunctions.shared.hideLoader()
                failure(encodingError)
            }
        }
    }
    
    func requestTwoImageUpload(_ strURL: String, _ params:[String:String], _ image:UIImage,_ degree:UIImage, success:@escaping (DataResponse<Any>) -> Void, failure:@escaping (Error) -> Void) {
        
        CommonFunctions.shared.showLoader()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            let imgData = image.jpegData(compressionQuality: 0.8)
            let degreeData = degree.jpegData(compressionQuality: 0.8)
            multipartFormData.append(imgData!, withName: "image",fileName: "image.png", mimeType: "image/png")
            multipartFormData.append(degreeData!, withName: "degree_certificate",fileName: "degree_certificate.png", mimeType: "image/png")
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: strURL) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    CommonFunctions.shared.showLoader(Float(progress.fractionCompleted))
                })
                upload.responseJSON { response in
                    CommonFunctions.shared.hideLoader()
                    if response.response?.statusCode == 200 {
                        success(response)
                    }else {
                        failure(response.result.error!)
                    }
                }
            case .failure(let encodingError):
                CommonFunctions.shared.hideLoader()
                failure(encodingError)
            }
        }
    }
}
