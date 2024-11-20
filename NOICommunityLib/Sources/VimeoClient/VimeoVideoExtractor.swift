// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoVideoExtractor.swift
//  
//
//  Created by Matteo Matassoni on 04/10/24.
//

import Foundation

public enum VimeoExtractorError: Error {
    case invalidVideoID
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noVideoURLFound
}

public protocol VimeoVideoExtractor {

    func fetchVideoURL(id: String, hash: String?) async throws -> VimeoVideo
}

public extension VimeoVideoExtractor {

    func fetchVideoURL(
        id: String,
        hash: String? = nil
    ) async throws -> VimeoVideo {
        try await fetchVideoURL(id: id, hash: hash)
    }

    func fetchVideoURL(from url: URL) async throws -> VimeoVideo {
        func extractIdAndHash(from url: URL) throws -> (
            id: String,
            hash: String?
        ) {
            let id = url.pathComponents.first {
                CharacterSet.decimalDigits.isSuperset(of: .init(charactersIn: $0))
            }

            guard let id, !id.isEmpty
            else { throw VimeoExtractorError.invalidVideoID }

            func extractHashFromPath() -> String? {
                url.pathComponents.first {
                    $0 != id && $0.count == 10 && $0.allSatisfy(\.isHexDigit)
                }?.lowercased()
            }

            func extractHashFromQueryParameters() -> String? {
                URLComponents(string: url.absoluteString)?.queryItems?.first { $0.name == "h" }?.value
            }

            let hash = extractHashFromPath() ?? extractHashFromQueryParameters()
            return (id, hash)
        }

        let (id, hash) = try extractIdAndHash(from: url)
        return try await fetchVideoURL(id: id, hash: hash)
    }

}
