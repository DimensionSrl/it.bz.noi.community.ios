// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Models.swift
//  ArticlesClient
//
//  Created by Matteo Matassoni on 10/05/22.
//

import Foundation

// MARK: - Language

public struct Language: RawRepresentable, Codable, Hashable {
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static let en = Self(rawValue: "en")
    public static let it = Self(rawValue: "it")
    public static let de = Self(rawValue: "de")
    
}

// MARK: - ArticleListResponse

public struct ArticleListResponse: Codable, Hashable {
    
    public let totalResults: Int
    
    public let totalPages: Int
    
    public let currentPage: Int
    
    public let previousPage: Int?
    
    public let nextPage: Int?
    
    public let items: [Article]?
    
    public init(
        totalResults: Int,
        totalPages: Int,
        currentPage: Int,
        previousPage: Int? = nil,
        nextPage: Int? = nil,
        items: [Article]? = nil
    ) {
        self.totalResults = totalResults
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.previousPage = previousPage
        self.nextPage = nextPage
        self.items = items
    }
    
}

// MARK: - Article

public struct Article: Codable, Hashable {
    
    public typealias LocalizedMap<T: Codable> = [String:T]
    
    public let id: String
    
    public let languageToDetails: LocalizedMap<Details>
    
    public let date: Date?
    
    public let languageToAuthor: LocalizedMap<ContactInfos>
    
    public let imageGallery: [ImageGallery]

    public let tags: [Tag]
    
    public var isImportant: Bool {
        tags.contains { $0.id == "important" }
    }

    public var languageToVideoItems: LocalizedMap<[VideoItem]>

    private enum CodingKeys: String, CodingKey {
        case id
        case date = "articleDate"
        case languageToDetails = "detail"
        case languageToAuthor = "contactInfos"
        case imageGallery
        case tags = "oDHTags"
        case languageToVideoItems = "videoItems"
    }

    struct AnyCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            return
        }

        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
            return
        }

        // Convenience initializer
        init(_ string: String) {
            self.stringValue = string
            self.intValue = nil
        }
    }

    enum VideoItemCodingKeys: String, CodingKey {
        case url
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
        self.languageToDetails = try container.decode(Article.LocalizedMap<Article.Details>.self, forKey: .languageToDetails)
        self.languageToAuthor = try container.decode(Article.LocalizedMap<Article.ContactInfos>.self, forKey: .languageToAuthor)
        self.imageGallery = try container.decodeIfPresent([Article.ImageGallery].self, forKey: .imageGallery) ?? []
        self.tags = try container.decodeIfPresent([Article.Tag].self, forKey: .tags) ?? []

        guard let localizedVideoItemsContainer = try? container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .languageToVideoItems)
        else {
            self.languageToVideoItems = [:]
            return
        }

        var languageToVideoItems: [String:[VideoItem]] = [:]
        for localizedKey in localizedVideoItemsContainer.allKeys {
            var videoItemsContainer = try localizedVideoItemsContainer.nestedUnkeyedContainer(forKey: localizedKey)
            var videoItems: [VideoItem] = []
            while !videoItemsContainer.isAtEnd {
                let videoItemContainer = try videoItemsContainer.nestedContainer(keyedBy: VideoItemCodingKeys.self)
                do {
                    let url = try videoItemContainer.decode(URL.self, forKey: .url)
                    let videoItem = VideoItem(url: url)
                    videoItems.append(videoItem)
                } catch {
                    print("Error while parsing video item: \(error)")
                }
            }
            languageToVideoItems[localizedKey.stringValue] = videoItems
        }
        
        self.languageToVideoItems = languageToVideoItems
    }

}

// MARK: Article.Details

extension Article {
    
    public struct Details: Codable, Hashable {
        
        public let title: String?
        
        public let abstract: String?
        
        public let text: String?
        
        private enum CodingKeys: String, CodingKey {
            case title = "title"
            case abstract = "additionalText"
            case text = "baseText"
        }
        
    }
    
}

// MARK: Article.ContactInfos

extension Article {
    
    public struct ContactInfos: Codable, Hashable {
        
        public let name: String?
        
        public let logoURL: URL?
        
        public let externalURL: URL?
        
        public let email: String?
        
        private enum CodingKeys: String, CodingKey {
            case name = "companyName"
            case logoURL = "logoUrl"
            case externalURL = "url"
            case email = "email"
        }
        
    }
    
}

// MARK: Article.ContactInfos

extension Article {
    
    public struct ImageGallery: Codable, Hashable {
        
        public let url: URL?
        
        private enum CodingKeys: String, CodingKey {
            case url = "imageUrl"
        }
        
    }
    
}

// MARK: Article.Tag

extension Article {
    
    public struct Tag: Codable, Hashable {
        public let id: String?
    }
    
}

// MARK: Article.VideoItem

extension Article {

    public struct VideoItem: Codable, Hashable {
        var url: URL
    }

}
