// This code accompanies a blog post: http://chris.eidhof.nl/posts/json-parsing-in-swift.html
//
// As of Beta5, the >>= operator is already defined, so I changed it to >>>=


import Foundation

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

struct Blog {
    let id: Int
    let name: String
    let needsPassword : Bool
    let url: NSURL
}

func parseBlog(blog: AnyObject) -> Blog? {
    let mkBlog = curry {id, name, needsPassword, url in Blog(id: id, name: name, needsPassword: needsPassword, url: url) }
    
    return asDict(blog) >>>= {
        mkBlog <*> int($0,"id")
            <*> string($0,"name")
            <*> bool($0,"needspassword")
            <*> (string($0, "url") >>>= toURL)
    }
}

func parse(blogData: [String:AnyObject]) -> Blog? {
    let makeBlog = curry { Blog(id: $0, name: $1, needsPassword: $2, url: $3) }
    
    return
        makeBlog <*> int(blogData,"id")
            <*> string(blogData,"name")
            <*> bool(blogData,"needspassword")
            <*> (string(blogData, "url") >>>= toURL)
}

func parseJSON() {
    let blogs = dictionary(parsedJSON, "blogs") >>>= {
        array($0, "blog") >>>= {
            join($0.map(parseBlog))
        }
    }
    
    switch blogs {
    case .Some (let a):
        println(a.reduce("", {$0 + $1.description + "\n"} ))
    default: return ()
    }

}

func parseJSON1() {
    let blogs = dictionary(parsedJSON, "blogs") >>>= {
        array($0, "blog") >>>= {
            join($0.map({asDict($0) >>>= parse}))
        }
    }
    
    switch blogs {
    case .Some (let a):
        println(a.reduce("", {$0 + $1.description + "\n"} ))
    default: return ()
    }
    
}


extension Blog : Printable {
    var description : String {
        return "Blog { id = \(id), name = \(name), needsPassword = \(needsPassword), url = \(url)"
    }
}

func toURL(urlString: String) -> NSURL {
    return NSURL(string: urlString)!
}


func asDict(x: AnyObject) -> [String:AnyObject]? {
    return x as? [String:AnyObject]
}


func join<A>(elements: [A?]) -> [A]? {
    var result : [A] = []
    for element in elements {
        if let x = element {
            result += [x]
        } else {
            return nil
        }
    }
    return result
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

func array(input: [String:AnyObject], key: String) ->  [AnyObject]? {
    let maybeAny : AnyObject? = input[key]
    return maybeAny >>>= { $0 as? [AnyObject] }
}

func dictionary(input: [String:AnyObject], key: String) ->  [String:AnyObject]? {
    return input[key] >>>= { $0 as? [String:AnyObject] }
}

func string(input: [String:AnyObject], key: String) -> String? {
    return input[key] >>>= { $0 as? String }
}

func number(input: [NSObject:AnyObject], key: String) -> NSNumber? {
    return input[key] >>>= { $0 as? NSNumber }
}

func int(input: [NSObject:AnyObject], key: String) -> Int? {
    return number(input,key).map { $0.integerValue }
}

func bool(input: [NSObject:AnyObject], key: String) -> Bool? {
    return number(input,key).map { $0.boolValue }
}


func curry<A,B,R>(f: (A,B) -> R) -> A -> B -> R {
    return { a in { b in f(a,b) } }
}

func curry<A,B,C,R>(f: (A,B,C) -> R) -> A -> B -> C -> R {
    return { a in { b in {c in f(a,b,c) } } }
}

func curry<A,B,C,D,R>(f: (A,B,C,D) -> R) -> A -> B -> C -> D -> R {
    return { a in { b in { c in { d in f(a,b,c,d) } } } }
}

infix operator  >>>= {}

func >>>= <A,B> (optional : A?, f : A -> B?) -> B? {
    return flatten(optional.map(f))
}

parseJSON()
parseJSON1()
