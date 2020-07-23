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
    public var resultsCount: Int? = 10
    public var language: QueryResultLanguage?
    public var constraints: [AddressQueryConstraint]?
    public var regionPriority: [RegionPriority]?
    public var upperScaleLimit: ScaleBound?
    public var lowerScaleLimit: ScaleBound?
    public var trimRegionResult: Bool = false
    
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
    ///`findByID` — takes KLADR or FIAS ID as a query parameter to lookup additional data.
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
    public var region                  : String?
    public var city                    : String?
    public var street_type_full        : String?
    public var settlement_type_full    : String?
    public var city_district_type_full : String?
    public var city_type_full          : String?
    public var area_type_full          : String?
    public var region_type_full        : String?
    public var country                 : String?
    public var country_iso_code        : String?
    public var region_iso_code         : String?
    public var kladr_id                : String?
    public var region_fias_id          : String?
    public var area_fias_id            : String?
    public var city_fias_id            : String?
    public var settlement_fias_id      : String?
    public var street_fias_id          : String?
    
    public init(
        region: String? = nil,
        city: String? = nil,
        street_type_full: String? = nil,
        settlement_type_full: String? = nil,
        city_district_type_full: String? = nil,
        city_type_full: String? = nil,
        area_type_full: String? = nil,
        region_type_full: String? = nil,
        country: String? = nil,
        country_iso_code: String? = nil,
        region_iso_code: String? = nil,
        kladr_id: String? = nil,
        region_fias_id: String? = nil,
        area_fias_id: String? = nil,
        city_fias_id: String? = nil,
        settlement_fias_id: String? = nil,
        street_fias_id: String? = nil
    ) {
        self.region = region
        self.city = city
        self.street_type_full = street_type_full
        self.settlement_type_full = settlement_type_full
        self.city_district_type_full = city_district_type_full
        self.city_type_full = city_type_full
        self.area_type_full = area_type_full
        self.region_type_full = region_type_full
        self.country = country
        self.country_iso_code = country_iso_code
        self.region_iso_code = region_iso_code
        self.kladr_id = kladr_id
        self.region_fias_id = region_fias_id
        self.area_fias_id = area_fias_id
        self.city_fias_id = city_fias_id
        self.settlement_fias_id = settlement_fias_id
        self.street_fias_id = street_fias_id
    }
}

///Helps prioritize specified region in search results by KLADR ID.
public struct RegionPriority: Encodable{
    public var kladr_id: String?
    
    public init(kladr_id: String?){ self.kladr_id = kladr_id }
}

///ScaleBound holds a value for `from_bound` and `to_bound` as a ScaleLevel.
///See
///[Dadata online API documentation](https://confluence.hflabs.ru/pages/viewpage.action?pageId=285343795) for API reference.
public struct ScaleBound: Encodable{
    public var value: ScaleLevel?
    
    public init(value: ScaleLevel?){ self.value = value }
}
