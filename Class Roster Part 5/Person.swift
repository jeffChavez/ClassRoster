//
//  Person.swift
//  Class Roster Part 5
//
//  Created by Jeff Chavez on 8/23/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit

class Person : NSObject, NSCoding {
    
    var firstName : String
    var lastName : String
    var photo : UIImage?
    
    init (firstName : String, lastName : String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    required init (coder aDecoder: NSCoder!) {
        self.firstName = aDecoder.decodeObjectForKey("firstName") as String
        self.lastName = aDecoder.decodeObjectForKey("lastName") as String
        if let myImage = aDecoder.decodeObjectForKey("photo") as? UIImage {
            self.photo = myImage
        }
    }
    
    func encodeWithCoder (aCoder: NSCoder!) {
        aCoder.encodeObject(self.firstName, forKey: "firstName")
        aCoder.encodeObject(self.lastName, forKey: "lastName")
        if self.photo != nil {
            aCoder.encodeObject(self.photo!, forKey: "photo")
        }
    }
    
    func fullName() -> String {
        
        return "\(self.firstName) \(self.lastName)"
    }

}