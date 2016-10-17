//: Playground - noun: a place where people can play

let input = "Aba-soft red-hard brown-Bab-hard orange-soft violet-Cen-thick yellow-quaint indigo-D'id-hard green-plaid blue"

let parse = input.characters.split(separator: "-")


class xor {
    
    let name:String
    let like:[String]
    let hate:[String]
    
    init(n:String,l:[String],h:[String]) {
        name = n
        like = l
        hate = h
    }
}

func SubtoString(seq:String.CharacterView.SubSequence) -> String {
    var output:String = ""
    for char in seq {
        output.append(char)
    }
    return output
}


let len = (parse.count / 3)
var peopleList:[xor] = []
for index in 0...len-1 {
    var name = SubtoString(seq: parse[index*3])
    var like = parse[index*3+1].split(separator: " ").map { word in
        SubtoString(seq: word)
    }
    var hate = parse[index*3+2].split(separator: " ").map { word in
        SubtoString(seq: word)
    }
    
    peopleList.append(xor.init(n: name, l: like, h: hate))
}


for i in 0...peopleList-1 {
    let x =
}






