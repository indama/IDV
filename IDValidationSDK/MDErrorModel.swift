//
//  MDError.swift
//  IDValidationSDK
//
//

import Foundation
//class MDErrorModel: MDBaseObject {
//    var type:String!
//    var developerMessage:String!
//    var message:String!
//    var moreInfo:String!
//    var code:NSNumber!
//    
//     required init(jsonData:AnyObject?) {
//        super.init(jsonData: jsonData)
//        loadProperties()
//    }
//    
//    required init(jsonString: String!) {
//        super.init(jsonString:jsonString)
//        loadProperties()
//    }
//
//    required init() {
//        super.init()
//    }
//    
//    init(jsonData: AnyObject?, withMessage message: String?) {
//        super.init(jsonData: jsonData)
//        self.loadProperties()
//        self.message = message
//    }
//    
//    func loadProperties(){
//        if self.jsonData != nil {
//            
//            self.type = Value<String>.get(self, key: "Type").or("")
//            self.developerMessage = Value<String>.get(self, key: "DeveloperMessage").or("")
//            if let m = Value<String>.get(self, key: "Message") {
//                self.message = m//Value<String!>.get(self, key: "Message").or("Some error occured, try again")
//            }else if let m = Value<String>.get(self, key: "error") {
//                self.message = m//Value<String!>.get(self, key: "Message").or("Some error occured, try again")
//            }else{
//                self.message = Value<String>.get(self, key: "Message").or("Some error occured, try again")
//            }
//            if let m = self.message, m.isEmpty, let e =  Value<String>.get(self, key: "error"){
//                self.message = e
//            }
//            
//            self.moreInfo = Value<String>.get(self, key: "MoreInfo").or("")
//            self.code = Value<NSNumber>.get(self, key: "Code").or(NSNumber())
//        }
//    }
//}
