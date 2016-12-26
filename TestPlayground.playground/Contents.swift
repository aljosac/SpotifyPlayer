//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let a = 2

let b = min(a,4)

ceil(Double(b)/2)

2.0 * 3.2

var l = [1,2,3,4,5]
var o:[Int] = []

// Removes all items that return true from eval function and retuns them as a list
func branch<T>( list:inout [T], eval:((T) -> Bool)) -> [T] {
    var count = l.count
    var loc = 0
    var ret:[T] = []
    while count-loc > 0 {
        if eval(list[loc]) {
            ret.append(list.remove(at: loc))
            count -= 1
        } else {
            loc += 1
        }
    }
    return ret
}

o = branch(list: &l, eval: {$0 % 2 == 1})
l
o