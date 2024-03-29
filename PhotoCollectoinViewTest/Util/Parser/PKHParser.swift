//
//  GlobalNSObject.swift
//  ssg
//
//  Created by pkh on 2018. 2. 6..
//  Copyright © 2018년 emart. All rights reserved.
//

import Foundation
import UIKit

public struct ParserMap {
    var ivar: String
    var jsonKey: String

    public init(ivar: String, jsonKey: String) {
        self.ivar = ivar
        self.jsonKey = jsonKey
    }
}

@inline(__always) public func checkObjectClass(_ obj: Any) -> Bool {
    if (obj is String) || (obj is NSNumber) || (obj is Dictionary<String, Any>) {
        return true
    }
    else {
        return false
    }
}

let ParserObjectConcurrentQueue = DispatchQueue(label: "ParserObjectConcurrentQueue", qos: .userInitiated, attributes: .concurrent)

@objcMembers open class PKHParser: NSObject {

    public override init() {
        super.init()
    }

    //    public class func parser(map dic : [String: Any], anyData: Any? = nil, serializeKey: String? = nil, completionHandler: @escaping (ParserObject) -> Void) {
    //        self.parser(map: dic, anyData: anyData, serializeKey: serializeKey, as: self, completionHandler: completionHandler)
    //    }

    public class func initAsync<T:PKHParser>(map dic : [String: Any]?, anyData: Any? = nil, serializeKey: String? = nil, completionHandler: @escaping (T) -> Void) {
        guard let dic = dic else { return }
        ParserObjectConcurrentQueue.async {
            let obj = T.init(map: dic, anyData: anyData, serializeKey: serializeKey)
            DispatchQueue.main.async(execute: {
                completionHandler(obj)
            })
        }

    }

    required public init(map dic: [String: Any], anyData: Any? = nil, serializeKey: String? = nil) {
        super.init()
        self.beforeParsed(dic:dic, anyData:anyData)
        if let key = serializeKey, let dataDic = dic[key] as? [String: Any] {
            self.setSerialize(map: dataDic, anyData: anyData)
            self.afterParsed(dataDic, anyData: anyData)
        }
        else {
            self.setSerialize(map: dic, anyData: anyData)
            self.afterParsed(dic, anyData: anyData)
        }


    }

    open func getDataMap() -> [ParserMap]? { return nil }
    open func beforeParsed(dic: [String: Any], anyData: Any?) {}
    open func afterParsed(_ dic: [String: Any], anyData: Any?) {}
    open func setSerialize(map dic: [String: Any], anyData: Any?) {

        let maps = self.getDataMap()
        let ivarList = self.ivarInfoList()
        for ivarItem in ivarList {
            var parserMaps = [ParserMap]()
            parserMaps.append(ParserMap(ivar: ivarItem.label, jsonKey: ivarItem.label))

            if let maps = maps {
                for pm in maps {
                    if pm.ivar == ivarItem.label {
                        parserMaps.append(pm)
                    }
                }
            }

            var data: Any? = nil
            for map in parserMaps {
                if let dicValue = dic[map.jsonKey]  {
                    data = dicValue
                    break
                }
            }
            //            print(changeKey)
            guard let value = data else { continue }
            guard value is NSNull == false else { continue }

            if ivarItem.classType == .array {
                guard let arrayValue = value as? [Any], arrayValue.count > 0 else { continue }
                guard let nsobjAbleType = ivarItem.subClassType as? PKHParser.Type else {
//                    assertionFailure("self : [\(self.className))] label : \(ivarItem.label)  \(String(describing: ivarItem.subClassType)) not NSObject" )
                    continue
                }
                var array: [Any] = []
                array.reserveCapacity(arrayValue.count)
                for arraySubDic in arrayValue {
                    if let dic = arraySubDic as? [String:Any], dic.isEmpty == false {
                        let addObj = nsobjAbleType.init(map: dic, anyData: anyData)
                        array.append(addObj)
                    }

                }
                self.setValue(array, forKey: ivarItem.label)
            }
            else if ivarItem.classType == .dictionary {
                guard let nsobjAbleType = ivarItem.subClassType as? PKHParser.Type else {
//                    assertionFailure("self : [\(self.className)] label : \(ivarItem.label)  \(String(describing: ivarItem.subClassType)) not NSObject" )
                    continue
                }
                if let dic = value as? [String:Any], dic.isEmpty == false {
                    let addObj = nsobjAbleType.init(map: dic, anyData: anyData)
                    self.setValue(addObj, forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .string {
                if value is String {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    self.setValue("\(value)", forKey: ivarItem.label)
                }

            }
            else if ivarItem.classType == .int {
                if value is Int {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toInt(), forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .float {
                if value is Float {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toFloat(), forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .cgfloat {
                if value is Float {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toCGFloat(), forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .double {
                if value is Float {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toDouble(), forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .bool {
                if value is Bool {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toBool(), forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .exceptType {
                continue
            }
            else {
                self.setValue(value, forKey: ivarItem.label)
            }
        }
    }

    override open var description: String {
        var result: [String] = []
        result.append("✏️ ======== \(self.className) ======== ✏️")
        let str = getDescription(1, mirrored_object: Mirror(reflecting: self))
        if str.isValid {
            result.append("\t\(str)")
        }
        result.append("✏️ ================== \(self.className) ===================== ✏️")
        return result.joined(separator: "\n")
    }

    private enum descriptionType {
        case `default`
        case array
        case subInstance
    }

    private func getDescription(_ tapCount: UInt = 1, mirrored_object: Mirror) -> String {
        var tap: String = ""
        for _ in 1...tapCount { tap += "\t" }
        var result: [String] = []

        if let parent: Mirror = mirrored_object.superclassMirror {
            let str = getDescription(tapCount, mirrored_object: parent)
            if str.isValid {
                result.append( str )
            }
        }

        for (label, value) in mirrored_object.children {
            guard let label = label else { continue }

            if value is String || value is Int || value is Float || value is CGFloat || value is Double || value is Bool {
                result.append("\(label) : \(value)")
            }
            else if let objList = value as? [PKHParser] {
                var strList = [String]()

                if objList.count > 0 {
                    for (idx, obj) in objList.enumerated() {
                        strList.append("[\(idx)] \(obj.getDescription(tapCount + 1, mirrored_object: Mirror(reflecting: obj)))")
                    }
                    result.append("\(label) : ⬇️ --- \(objList[safe: 0]?.className ?? "count = 0") ⬇️ ------")
                    result.append(contentsOf: strList)
                    result.append("------------------------------------------------------------")
                }
                else {
                    result.append("\(label) : ⬇️ --- count = 0 ⬇️ ------")
                }

            }
            else if let objList = value as? [String] {
                var strList = [String]()
                for (idx, obj) in objList.enumerated() {
                    strList.append("\t[\(idx)] \(obj)")
                }
                result.append("\(label) : ⬇️ --- String ⬇️ ------")
                result.append(contentsOf: strList)
                result.append("--------------------------------------------------------------")
            }

            else if let obj = value as? PKHParser {
                result.append("\(label) : ➡️ === \(obj.className) ======")
                result.append("\t\(obj.getDescription(tapCount + 1, mirrored_object: Mirror(reflecting: obj)))")
                result.append("======= \(obj.className) ===============================")
            }
            else {
                result.append("\(label) : \(value)")
            }
        }

        return result.joined(separator: "\n\(tap)")
    }

}

