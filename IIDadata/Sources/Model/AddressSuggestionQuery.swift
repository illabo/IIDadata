//
//  AddressSuggestionQuery.swift
//  IIDadata
//
//  Created by Yachin Ilya on 12.05.2020.
//

import Foundation

///AddressSuggestionQuery represents an serializable object used to perform certain queries.
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
    
    ///New instance of AddressSuggestionQuery defaulting to simple address suggestions request.
    ///- Parameter query: Query string to be sent to API.
    public convenience init(_ query: String){
        self.init(query, ofType: .address)
    }
    
    ///New instance of AddressSuggestionQuery.
    ///- Parameter query: Query string to be sent to API.
    ///- Parameter ofType: Type of request to send to API.
    ///It could be of type
    ///`address` — standart address suggestion query;
    ///`fiasOnly` — query to only search in FIAS database: less matches, state provided address data only;
    ///`findByID` — takes KLADR or FIAS ID as a qury parameter to lookup additional data.
    public required init(_ query: String, ofType type: AddressQueryType){
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
    
    ///Serializes AddressSuggestionQuery to send over the wire.
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
    
    ///Returns an API endpoint for different request types:
    ///`address` — "suggest/address"
    ///`fiasOnly` — "suggest/fias"
    ///`findByID` — "findById/address"
    func queryEndpoint() -> String { return queryType.rawValue }
}

///Levels of `from_bound` and `to_bound` according to
///[Dadata online API documentation](https://confluence.hflabs.ru/pages/viewpage.action?pageId=285343795).
public enum ScaleLevel: String, Encodable {
    case country = "country"
    case region = "region"
    case area = "area"
    case city = "city"
    case settlement = "settlement"
    case street = "street"
    case house = "house"
}

///AddressQueryConstraint used to limit search results according to
///[Dadata online API documentation](https://confluence.hflabs.ru/pages/viewpage.action?pageId=204669108).
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

///Helps prioritize specified region in search results by KLADR ID.
public struct RegionPriority: Encodable{
    var kladr_id: String?
}

///ScaleBound holds a value for `from_bound` and `to_bound` as a ScaleLevel.
///See
///[Dadata online API documentation](https://confluence.hflabs.ru/pages/viewpage.action?pageId=285343795) for API reference.
struct ScaleBound: Encodable{
    var value: ScaleLevel?
}
