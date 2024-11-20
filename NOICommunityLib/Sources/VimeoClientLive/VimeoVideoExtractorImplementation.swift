// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoVideoExtractorImplementation.swift
//
//
//  Created by Matteo Matassoni on 04/10/24.
//

import Foundation
import Core
import VimeoClient

// MARK: - VimeoVideoExtractorImplementation

public actor VimeoVideoExtractorImplementation: VimeoVideoExtractor {

    private let transport: Transport
    private let jsonDecoder = JSONDecoder()

    public init(transport: Transport) {
        self.transport = transport
            .checkingStatusCodes()
            .addingJSONHeaders()
    }

    public func fetchVideoURL(
        id: String,
        hash: String? = nil
    ) async throws -> VimeoVideo {
        let playerURL = try Self.playerURL(forVideoWithId: id, hash: hash)
        do {
            let (data, _) = try await transport.get(from: playerURL)

            try Task.checkCancellation()

            let response = try jsonDecoder.decode(
                VimeoResponse.self,
                from: data
            )
            return try VimeoVideo(from: response)
        } catch let error as DecodingError {
            throw VimeoExtractorError.decodingError(error)
        } catch let error as StatusCodeError {
            throw VimeoExtractorError.networkError(error)
        } catch let error as URLError {
            throw VimeoExtractorError.networkError(error)
        } catch {
            throw error
        }
    }
}

// MARK: Private APIs

private extension VimeoVideoExtractorImplementation {

    static func playerURL(
        forVideoWithId id: String,
        hash: String?
    ) throws -> URL {
        guard var urlComponents = URLComponents(
            string: "https://player.vimeo.com/video/\(id)/config"
        )
        else { throw VimeoExtractorError.invalidURL }

        if let hash {
            urlComponents.queryItems = [.init(name: "h", value: hash)]
        }
        
        guard let url = urlComponents.url
        else { throw VimeoExtractorError.invalidURL }

        return url
    }

}

