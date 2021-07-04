//
//  File.swift
//  IDValidationSDK
//
//

import Foundation



class MDDirectValidationModel {
    
    var selfieImageId: Int!
    var frontId: Int!
    var backId: Int!

    
    var selfieImage: String!
    var front: String!
    var back: String!
    var email: String!
    var phoneNumber: String!
    var last4Ssn: String!
    var type: Int!
    
    var address: String!
    var City: String!
    var DateOfBirth: String!
    var FirstName: String!
    var State: Int!
    var LastName: String!
    var Zip: String!
}

class DirectValidationStatusModel {
    
    var faceImageId: Int?
    var frontImageId: Int?
    var Success: Bool = true
    var Message: String?
    
}
