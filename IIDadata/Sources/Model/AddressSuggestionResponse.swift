//
//  Models Generated using http://www.jsoncafe.com/
//  Created on May 11, 2020

import Foundation

///AddressSuggestionResponse represents a deserializable object used to hold API response.
public struct AddressSuggestionResponse : Decodable {
	public let suggestions : [AddressSuggestions]?
}

///Every single suggestion is represented as AddressSuggestions.
public struct AddressSuggestions : Decodable {
    ///Address in short format.
    public let value : String?
    ///All the data returned in response to suggestion query.
    public let data : AddressSuggestionData?
    ///Address in long format with region.
    public let unrestrictedValue : String?
    
    enum CodingKeys: String, CodingKey {
        case value
        case data
        case unrestrictedValue = "unrestricted_value"
    }
}

///All the data returned in response to suggestion query.
public struct AddressSuggestionData : Decodable {
    public let area : String?
    public let areaFiasId : String?
    public let areaKladrId : String?
    public let areaType : String?
    public let areaTypeFull : String?
    public let areaWithType : String?
    public let beltwayDistance : String?
    public let beltwayHit : String?
    public let block : String?
    public let blockType : String?
    public let blockTypeFull : String?
    public let building : String?
    public let buildingType : String?
    public let cadastralNumber : String?
    public let capitalMarker : String?
    public let city : String?
    public let cityArea : String?
    public let cityDistrict : String?
    public let cityDistrictFiasId : String?
    public let cityDistrictKladrId : String?
    public let cityDistrictType : String?
    public let cityDistrictTypeFull : String?
    public let cityDistrictWithType : String?
    public let cityFiasId : String?
    public let cityKladrId : String?
    public let cityType : String?
    public let cityTypeFull : String?
    public let cityWithType : String?
    public let country : String?
    public let countryIsoCode : String?
    public let federalDistrict : String?
    public let fiasActualityState : String?
    public let fiasCode : String?
    public let fiasId : String?
    public let fiasLevel : String?
    public let flat : String?
    public let flatArea : String?
    public let flatPrice : String?
    public let flatType : String?
    public let flatTypeFull : String?
    public let geoLat : String?
    public let geoLon : String?
    public let geonameId : String?
    public let historyValues : [String]?
    public let house : String?
    public let houseFiasId : String?
    public let houseKladrId : String?
    public let houseType : String?
    public let houseTypeFull : String?
    public let kladrId : String?
    public let metro : [Metro]?
    public let okato : String?
    public let oktmo : String?
    public let planningStructure : String?
    public let planningStructureFiasId : String?
    public let planningStructureKladrId : String?
    public let planningStructureType : String?
    public let planningStructureTypeFull : String?
    public let planningStructureWithType : String?
    public let postalBox : String?
    public let postalCode : String?
    public let qc : String?
    public let qcComplete : String?
    public let qcGeo : String?
    public let qcHouse : String?
    public let region : String?
    public let regionFiasId : String?
    public let regionIsoCode : String?
    public let regionKladrId : String?
    public let regionType : String?
    public let regionTypeFull : String?
    public let regionWithType : String?
    public let settlement : String?
    public let settlementFiasId : String?
    public let settlementKladrId : String?
    public let settlementType : String?
    public let settlementTypeFull : String?
    public let settlementWithType : String?
    public let source : String?
    public let squareMeterPrice : String?
    public let street : String?
    public let streetFiasId : String?
    public let streetKladrId : String?
    public let streetType : String?
    public let streetTypeFull : String?
    public let streetWithType : String?
    public let taxOffice : String?
    public let taxOfficeLegal : String?
    public let timezone : String?
    public let unparsedParts : String?
    
    enum CodingKeys: String, CodingKey {
        case area = "area"
        case areaFiasId = "area_fias_id"
        case areaKladrId = "area_kladr_id"
        case areaType = "area_type"
        case areaTypeFull = "area_type_full"
        case areaWithType = "area_with_type"
        case beltwayDistance = "beltway_distance"
        case beltwayHit = "beltway_hit"
        case block = "block"
        case blockType = "block_type"
        case blockTypeFull = "block_type_full"
        case building = "building"
        case buildingType = "building_type"
        case cadastralNumber = "cadastral_number"
        case capitalMarker = "capital_marker"
        case city = "city"
        case cityArea = "city_area"
        case cityDistrict = "city_district"
        case cityDistrictFiasId = "city_district_fias_id"
        case cityDistrictKladrId = "city_district_kladr_id"
        case cityDistrictType = "city_district_type"
        case cityDistrictTypeFull = "city_district_type_full"
        case cityDistrictWithType = "city_district_with_type"
        case cityFiasId = "city_fias_id"
        case cityKladrId = "city_kladr_id"
        case cityType = "city_type"
        case cityTypeFull = "city_type_full"
        case cityWithType = "city_with_type"
        case country = "country"
        case countryIsoCode = "country_iso_code"
        case federalDistrict = "federal_district"
        case fiasActualityState = "fias_actuality_state"
        case fiasCode = "fias_code"
        case fiasId = "fias_id"
        case fiasLevel = "fias_level"
        case flat = "flat"
        case flatArea = "flat_area"
        case flatPrice = "flat_price"
        case flatType = "flat_type"
        case flatTypeFull = "flat_type_full"
        case geoLat = "geo_lat"
        case geoLon = "geo_lon"
        case geonameId = "geoname_id"
        case historyValues = "history_values"
        case house = "house"
        case houseFiasId = "house_fias_id"
        case houseKladrId = "house_kladr_id"
        case houseType = "house_type"
        case houseTypeFull = "house_type_full"
        case kladrId = "kladr_id"
        case metro = "metro"
        case okato = "okato"
        case oktmo = "oktmo"
        case planningStructure = "planning_structure"
        case planningStructureFiasId = "planning_structure_fias_id"
        case planningStructureKladrId = "planning_structure_kladr_id"
        case planningStructureType = "planning_structure_type"
        case planningStructureTypeFull = "planning_structure_type_full"
        case planningStructureWithType = "planning_structure_with_type"
        case postalBox = "postal_box"
        case postalCode = "postal_code"
        case qc = "qc"
        case qcComplete = "qc_complete"
        case qcGeo = "qc_geo"
        case qcHouse = "qc_house"
        case region = "region"
        case regionFiasId = "region_fias_id"
        case regionIsoCode = "region_iso_code"
        case regionKladrId = "region_kladr_id"
        case regionType = "region_type"
        case regionTypeFull = "region_type_full"
        case regionWithType = "region_with_type"
        case settlement = "settlement"
        case settlementFiasId = "settlement_fias_id"
        case settlementKladrId = "settlement_kladr_id"
        case settlementType = "settlement_type"
        case settlementTypeFull = "settlement_type_full"
        case settlementWithType = "settlement_with_type"
        case source = "source"
        case squareMeterPrice = "square_meter_price"
        case street = "street"
        case streetFiasId = "street_fias_id"
        case streetKladrId = "street_kladr_id"
        case streetType = "street_type"
        case streetTypeFull = "street_type_full"
        case streetWithType = "street_with_type"
        case taxOffice = "tax_office"
        case taxOfficeLegal = "tax_office_legal"
        case timezone = "timezone"
        case unparsedParts = "unparsed_parts"
    }
}

public struct Metro: Decodable{
    public let name : String?
    public let line : String?
    public let distance : String?
}
