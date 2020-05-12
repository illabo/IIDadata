//
//  AddressSuggestionQuery.swift
//  IIDadata
//
//  Created by Yachin Ilya on 12.05.2020.
//

import Foundation

public class AddressSuggestionQuery: Encodable, DadataQueryProtocol{
    let query: String
    let queryType: AddressQueryType
    var resultsCount: Int? = 10
    var language: QueryResultLanguage?
    var constraints: [AddressQueryConstraint]?
    var regionPriority: [RegionPriority]?
    var upperScaleLimit: ScaleBound?
    var lowerScaleLimit: ScaleBound?
    var trimRegionResult: Bool = false
    
    convenience init(_ query: String){
        self.init(query, ofType: .address)
    }
    
    required init(_ query: String, ofType type: AddressQueryType){
        self.query = query
        self.queryType = type
    }
    
    enum CodingKeys: String, CodingKey {
        case query
        case resultsCount = "count"
        case language
        case constraints = "locations"
        case regionPriority = "locations_boost"
        case upperScaleLimit = "from_bound"
        case lowerScaleLimit = "to_bound"
        case trimRegionResult = "restrict_value"
    }
    
    func toJSON() throws -> Data {
        if constraints?.isEmpty ?? false { constraints = nil }
        if regionPriority?.isEmpty ?? false { regionPriority = nil }
        if let upper = upperScaleLimit,
            let lower = lowerScaleLimit,
            upper.value == nil || lower.value == nil {
            upperScaleLimit = nil
            lowerScaleLimit = nil
        }
        return try JSONEncoder().encode(self)
    }
    
    func queryEndpoint() -> String { return queryType.rawValue }
}

public enum ScaleLevel: String, Encodable {
    case country = "country"
    case region = "region"
    case area = "area"
    case city = "city"
    case settlement = "settlement"
    case street = "street"
    case house = "house"
}

public struct AddressQueryConstraint: Codable{
    var region: String?
    var city: String?
    var street_type_full: String?
    var settlement_type_full: String?
    var city_district_type_full: String?
    var city_type_full: String?
    var area_type_full: String?
    var region_type_full: String?
    var country: String?
    var country_iso_code: String?
    var region_iso_code: String?
    var kladr_id: String?
    var region_fias_id: String?
    var area_fias_id: String?
    var city_fias_id: String?
    var settlement_fias_id: String?
    var street_fias_id: String?
}

public struct RegionPriority: Encodable{
    var kladr_id: String?
}

struct ScaleBound: Encodable{
    var value: ScaleLevel?
}
