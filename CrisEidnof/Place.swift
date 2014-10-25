//
//  Place.swift
//  CrisEidnof
//
//  Created by Tatiana Kornilova on 10/8/14.
//  Copyright (c) 2014 Tatiana Kornilova. All rights reserved.
//

import Foundation
struct Place: Printable {
    let placeURL: String
    let timeZone: String
    let photoCount : String
    let content : String
    
    
    var description : String {
        return "Place { placeURL = \(placeURL), timeZone = \(timeZone), photoCount = \(photoCount),content = \(content)} \n"
    }
    typealias J = Place
    
    
    static func create(placeURL: String)(timeZone: String)(photoCount: String)(content: String) -> Place {
        return Place(placeURL: placeURL, timeZone: timeZone, photoCount: photoCount,content: content)
    }
    
    static func parsePlace(blog: AnyObject) -> Place? {
        return asDict(blog) >>> {
            return (Place.create <*> string($0,"place_url")
                <*> string($0,"timezone")
                <*> string($0,"photo_count")
                <*> string($0,"_content"))
        }
    }
}
