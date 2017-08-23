//
//  ext.swift
//  test-kds-bug
//
//  Created by Rob on 19/08/2017.
//  Copyright © 2017 Rob. All rights reserved.
//

import Foundation
import CoreML

let model = kds()


extension kds{

    func optpredict(from input: kdsInput, options: MLPredictionOptions) throws -> kdsOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        let result = kdsOutput(output1: outFeatures.featureValue(for: "output1")!.multiArrayValue!)
        return result
    }
}


extension String {
    // String extensions taken from SO: https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift-3
    // Makes it behave like a normal language :)
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    }
    
}

func removeConsecRepeated(str: String) -> String{
    //test if characters next to each other are the same
    //in for loop start at pos i, check pos i+1:
    //      if i == i+1 then "delete" i+1
    //      else continue
    var newstr = String()
    for (i,c) in str.enumerated(){
        if(i >= str.length){
            break
        }
        else if(str[i] == str[i+1]){
            continue
        }else{
            newstr.append(c)
        }
    }
    return newstr
}


func argMaxDecode(t: [Double]) -> String {
    
    var max_val = 0 as Double
    var max_pos = 0 as Int
    
    // find biggest value - there's no numpy in swift
    for (i,x) in (t.enumerated()){
        if(x > max_val){
            max_val = x
            max_pos = Int(i)
        }
    }
    
    // this is a POC - hacky but quick
    // map biggest value position to a letter
    switch max_pos {
    case 0:
        return " "
    case 1:
        return "a"
    case 2:
        return "b"
    case 3:
        return "c"
    case 4:
        return "d"
    case 5:
        return "e"
    case 6:
        return "f"
    case 7:
        return "g"
    case 8:
        return "h"
    case 9:
        return "i"
    case 10:
        return "j"
    case 11:
        return "k"
    case 12:
        return "l"
    case 13:
        return "m"
    case 14:
        return "n"
    case 15:
        return "o"
    case 16:
        return "p"
    case 17:
        return "q"
    case 18:
        return "r"
    case 19:
        return "s"
    case 20:
        return "t"
    case 21:
        return "u"
    case 22:
        return "v"
    case 23:
        return "w"
    case 24:
        return "x"
    case 25:
        return "y"
    case 26:
        return "z"
    default:
        //ctc char
        return "_"
    }
}
