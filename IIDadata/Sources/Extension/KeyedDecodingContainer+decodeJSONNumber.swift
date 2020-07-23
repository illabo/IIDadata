//
//  KeyedDecodingContainer+decodeJSONNumber.swift
//  IIDadata
//
//  Created by Yachin Ilya on 23.07.2020.
//

import Foundation

extension KeyedDecodingContainer {
    /// Forces integers and floating point numbers to optional String type.
    /// Helpful when JSON response may include inconsistency in number fields.
    /// - parameter key: CodingKey of Decodable object CodingKeys to lookup.
    func decodeJSONNumber(forKey key: CodingKey) -> String? {
        if let v = try? decode(String.self, forKey: key as! K) {
            return v
        }
        if let v = try? decode(Int.self, forKey: key as! K) {
            return "\(v)"
        }
        if let v = try? decode(Double.self, forKey: key as! K) {
            return "\(v)"
        }
        return nil
    }
}
