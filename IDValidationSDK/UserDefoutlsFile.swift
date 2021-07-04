//
//  UserDefoutlsFile.swift
//  IDValidationSDK
//
//

import Foundation


extension  UserDefaults{
    class func IDAttemptCount(_ value:Int) {
        UserDefaults.setObject(value, forKey: FIELD_ID_ATTEMPT_COUNT)
    }
    
    class func IDAttemptCount() -> Int {
        if let t = UserDefaults.objectForKey(FIELD_ID_ATTEMPT_COUNT)?.int32Value {
            return Int(t)
        } else {
            return 1
        }
    }
    
}
