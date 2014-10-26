//
//  JSON.swift
//  CrisEidnof
//
//  Created by Tatiana Kornilova on 10/8/14.
//  Copyright (c) 2014 Tatiana Kornilova. All rights reserved.
//

import Foundation

//------ Операторы функционального программирования ----------

infix operator  >>> {associativity left precedence 150}
func >>> <A,B> (optional : A?, f : A -> B?) -> B? {
    return flatten(optional.map(f))
}

infix operator  <^> { associativity left precedence 150 }
func <^><A, B>(f: A -> B, a: A?) -> B? {
    if let x = a {
        return (f(x))
    } else {
        return .None
    }
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
//---------------------Новые операторы --------
//  Для извлечения словаря

infix operator  |> { associativity left precedence 150 }
func |>(input: [String:AnyObject]?, key: String) ->  [String:AnyObject]? {
    return input![key] >>> { $0 as? [String:AnyObject] }
}

//  Для извлечения массива

infix operator  ||> { associativity left precedence 150 }
func ||>(input: [String:AnyObject]?, key: String) ->  [AnyObject]? {
    return input![key] >>> { $0 as? [AnyObject] }
}
//-------------- Функции ----------------

func flatten<A>(x: A??) -> A? {
    if let y = x { return y }
    return nil
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

func asDict(x: AnyObject) -> [String:AnyObject]? {
    return x as? [String:AnyObject]
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


