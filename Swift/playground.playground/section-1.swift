// Playground - noun: a place where people can play

import UIKit


let priceInferred = 19.99
let priceExplicit: Double = 19.99

let onSaleInferred = true
let onSaleExplicit: Bool = false

let onRight = true

let nameInferred = "Whoopie Cushion"
let nameExplicit: String = "!Whoopie Cushion"

if onRight {
    println("\(nameInferred) on sale for \(priceInferred)!")
} else {
    println("\(nameExplicit) at regular price: \(priceInferred)!")
}


class TipCalculator{
    // 2
    let total: Double
    let taxPct: Double
    let subtotal: Double
    
    // 3
    init(total:Double, taxPct:Double) {
        self.total = total
        self.taxPct = taxPct
        subtotal = total / (taxPct + 1)
    }
    
    // 4
    func calcTipWithTipPct(tipPct:Double) -> Double {
        return subtotal * tipPct
    }
    
    // 5
    func printPossibleTips() {
        println("15%: \(calcTipWithTipPct(0.15))")
        println("18%: \(calcTipWithTipPct(0.18))")
        println("20%: \(calcTipWithTipPct(0.20))")
    }
}

// 6
let tipCalc = TipCalculator(total: 33.25, taxPct: 0.06)
tipCalc.printPossibleTips()


2530*2+600*5
2530*2+360*5

enum ServerResponse {
    case Result(String, String)
    case Error(String)
    case Unknow(String)
}

let success = ServerResponse.Result("6:00 am", "8:09 pm")
let failure = ServerResponse.Error("Out of cheese.")

switch success {
case let .Result(sunrise, sunset):
    let serverResponse = "Sunrise is at \(sunrise) and sunset is at \(sunset)."
case let .Error(error):
    let serverResponse = "Failure...  \(error)"
case let .Unknow(msg):
    let serverResponse = "unknow \(msg)"
    
}

protocol ExampleProtocol {
    var simpleDescription: String { get }
    mutating func adjust()
}
struct SimpleStructure: ExampleProtocol {
    var simpleDescription: String = "A simple structure"
    mutating func adjust() {
        simpleDescription += " (adjusted)"
    }
}
var b = SimpleStructure()
b.adjust()
let bDescription = b.simpleDescription
enum Suit {
    case Spades, Hearts, Diamonds, Clubs
    func simpleDescription() -> String {
        switch self {
        case .Spades:
            return "spades"
        case .Hearts:
            return "hearts"
        case .Diamonds:
            return "diamonds"
        case .Clubs:
            return "clubs"
        }
    }
    
}
enum SimpleEnum: ExampleProtocol {
    case Enum1, Enum2
    var simpleDescription: String {
        get {
            switch self {
            case .Enum1:
                return "Enum 1."
            case .Enum2:
                return "Enum 2."
            }
        }
        set {
            simpleDescription = newValue
        }
    }
    mutating func adjust() {
        simpleDescription += " (adjusted)"
    }
}

let myMoney: String?="1003030"
println(myMoney!)

class Project{
    var id: Int
    var addTime: Int
    var modifiedTime: Int
    var name: String
    var path: String
    var zip: String
    
    init(id: Int,name: String,path: String, zip:String, addTime: Int, modifiedTime: Int){
        self.id = id
        self.name = name
        self.path = path
        self.zip = zip
        self.addTime = addTime
        self.modifiedTime = modifiedTime
    }
    
    func description() -> String{
        let addTime = NSDate(timeIntervalSince1970: NSTimeInterval(self.addTime));
        let modifiedTime = NSDate(timeIntervalSince1970: NSTimeInterval(self.modifiedTime));
        
        return "id:\(id),name:\(name),\npath:\(path),zip:\(zip),addTime:\(addTime),modifiedTime:\(modifiedTime)";
    }
    
}
let ss?="a"
let pj = Project(id: 20, name: ss, path: "what", zip: "good", addTime: 141, modifiedTime: 123)
println(pj)



