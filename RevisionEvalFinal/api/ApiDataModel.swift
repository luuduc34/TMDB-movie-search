//
//  ApiDataModel.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 20/10/2023.
//

import Foundation

// MARK: - MovieResponse
struct MovieResponse: Codable {
    let results: [Result]
    
}

// MARK: - Result
struct Result: Codable, Identifiable {
    let backdropPath: String?
    let genreIDS: [Int]
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate, title: String
    let voteAverage: Double
    let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
// pour youtube
// MARK: - MovieResponse
struct VideoResponse: Codable {
    let id: Int
    let results: [ResultVideo]
}

// MARK: - Result
struct ResultVideo: Codable {
    let iso639_1, iso3166_1, name, key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let publishedAt, id: String

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name, key, site, size, type, official
        case publishedAt = "published_at"
        case id
    }
}
