// Playground - noun: a place where people can play

import Foundation

//=====
let parsedJSON : [String:AnyObject] = [
    "stat": "ok",
    "blogs": [
        "blog": [
            [
                "id" : 73,
                "name" : "Bloxus test",
                "needspassword" : true,
                "url" : "http://remote.bloxus.com/"
            ],
            [
                "id" : 74,
                "name" : "Manila Test",
                "needspassword" : false,
                "url" : "http://flickrtest1.userland.com/"
            ]
        ]
    ]
]

struct Blog : Printable {
    let id: Int
    let name: String
    let needsPassword : Bool
    let url: NSURL
    var description : String {
        return "Blog { id = \(id), name = \(name), needsPassword = \(needsPassword), url = \(url)}"
    }
    static func create(id: Int)(name: String)(needsPassword: Int)(url:String) -> Blog {
        return Blog(id: id, name: name, needsPassword: Bool(needsPassword), url: toURL(url))
    }
    static func parseBlog(blog: AnyObject) -> Blog? {
        return asDict(blog) >>> {
            return (Blog.create <*> int($0,"id")
                <*> string($0,"name")
                <*> int($0,"needspassword")
                <*> string($0, "url"))
        }
    }

}

func decodeJSON(data: NSData) -> [String:AnyObject]? {
    var jsonErrorOptional: NSError?
    let jsonOptional: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
    if let json:AnyObject = jsonOptional {
        return asDict(json)
    } else {
        return .None
    }
}

func pure<A>(value: A) -> A? {
    return value
}


infix operator  <^> { associativity left precedence 150 }
func <^><A, B>(f: A -> B, a: A?) -> B? {
    if let x = a {
        return (f(x))
    } else {
        return .None
    }
}


infix operator  >>> {}

func >>> <A,B> (optional : A?, f : A -> B?) -> B? {
    return flatten(optional.map(f))
}

infix operator  <*> { associativity left precedence 150 }
func <*><A, B>(l: (A -> B)?, r: A?) -> B? {
    if let l1 = l {
        if let r1 = r {
            return l1(r1)
        }
    }
    return nil
}

func flatten<A>(x: A??) -> A? {
    if let y = x { return y }
    return nil
}


func asDict(x: AnyObject) -> [String:AnyObject]? {
    return x as? [String:AnyObject]
}


func join<A>(elements: [A?]) -> [A]? {
    var result : [A] = []
    for element in elements {
        if let x = element {
            result.append(x)
        } else {
            return nil
        }
    }
    return result
}


func array(input: [String:AnyObject], key: String) ->  [AnyObject]? {
    return input[key] >>> { $0 as? [AnyObject] }
}

func dictionary(input: [String:AnyObject], key: String) ->  [String:AnyObject]? {
    return input[key] >>> { $0 as? [String:AnyObject] }
}

func string(input: [String:AnyObject], key: String) -> String? {
    return input[key] >>> { $0 as? String }
}

func number(input: [NSObject:AnyObject], key: String) -> NSNumber? {
    return input[key] >>> { $0 as? NSNumber }
}

func int(input: [NSObject:AnyObject], key: String) -> Int? {
    return number(input,key).map { $0.integerValue }
}

func bool(input: [NSObject:AnyObject], key: String) -> Bool? {
    return number(input,key).map { $0.boolValue }
}

func parseJSON() {
    let blogs:[Blog]? = dictionary(parsedJSON, "blogs") >>> {
        array($0, "blog") >>> {
            join($0.map(Blog.parseBlog))
        }
    }
    for blg in blogs! {
        println("\(blg.description)")
    }
}


func toURL(urlString: String) -> NSURL {
    return NSURL(string: urlString)!
}

parseJSON()

//======
var jsonString = "{ \"stat\": \"ok\", \"blogs\": { \"blog\": [ { \"id\" : 73, \"name\" : \"Bloxus test\", \"needspassword\" : true, \"url\" : \"http://remote.bloxus.com/\" }, { \"id\" : 74, \"name\" : \"Manila Test\", \"needspassword\" : false, \"url\" : \"http://flickrtest1.userland.com/\" } ] } }"
let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

var blogs2:[Blog]? = jsonData >>> {decodeJSON ($0)
                              >>> {dictionary($0,"blogs")
                              >>> { array($0, "blog") >>> {
                             join($0.map(Blog.parseBlog))
            }
        }
    }
}
var parsedJSON1 =  jsonData >>> decodeJSON
let blogs1:[Blog]? = dictionary(parsedJSON1!,"blogs") >>> {
                                    array($0, "blog") >>> {
                                   join($0.map(Blog.parseBlog))
    }
}
for blg in blogs2! {
    println("\(blg.description)")
}

//=====

