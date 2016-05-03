//
//  Alamofire+CustomRequests.swift
//  Vendee
//
//  Created by Ashish Kayastha on 10/28/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import Alamofire
//import Ono

extension Alamofire.Request {
    
//    public static func XMLResponseSerializer() -> ResponseSerializer<ONOXMLDocument, NSError> {
//        return ResponseSerializer { _, _, data, error in
//            guard error == nil else { return .Failure(error!) }
//            
//            guard let validData = data else {
//                let failureReason = "Data could not be serialized. Input data was nil."
//                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
//                return .Failure(error)
//            }
//            
//            do {
//                let XML = try ONOXMLDocument(data: validData)
//                return .Success(XML)
//            } catch {
//                return .Failure(error as NSError)
//            }
//        }
//    }
//    
//    public func responseXMLDocument(completionHandler: Response<ONOXMLDocument, NSError> -> Void) -> Self {
//        return response(responseSerializer: Request.XMLResponseSerializer(), completionHandler: completionHandler)
//    }
    
    public static func imageResponseSerializer() -> ResponseSerializer<UIImage, NSError> {
        return ResponseSerializer { _, _, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            guard let image = UIImage(data: validData, scale: UIScreen.mainScreen().scale) else {
                let failureReason = "Image could not be read."
                let error = Error.errorWithCode(.InputStreamReadFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            return .Success(image)
        }
    }
    
    public func responseImage(completionHandler: Response<UIImage, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.imageResponseSerializer(), completionHandler: completionHandler)
    }
}
