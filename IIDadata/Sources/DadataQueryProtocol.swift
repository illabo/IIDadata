//
//  DadataQueryProtocol.swift
//  IIDadata
//
//  Created by Yachin Ilya on 12.05.2020.
//

import Foundation

protocol DadataQueryProtocol {
    func queryEndpoint() -> String
    func toJSON() throws -> Data
}


