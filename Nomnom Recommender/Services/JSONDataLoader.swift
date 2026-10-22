//
//  JSONDataLoader.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 22/10/26.
//

import Foundation

enum JSONDataLoader {
    static func load<T: Decodable>(
        _ type: T.Type,
        from filename: String
    ) throws -> T {
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "json"
        ) else {
            throw DataError.fileNotFound(filename)
        }
        
        let data = try Data(contentsOf: url)
        
        return try JSONDecoder().decode(
            type,
            from: data
        )
    }
    
    enum DataError: LocalizedError {
        case fileNotFound(String)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let filename):
                return "Could not find \(filename).json in the app bundle."
            }
        }
    }
}
