// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoClientImplementation.swift
//
//
//  Created by Matteo Matassoni on 04/10/24.
//

import Foundation
import Combine
import class UIKit.UIImage
import Core
import VimeoClient

public class VimeoClientImplementation: VimeoClient {

    private let transport: Transport
    private let decoder = JSONDecoder()

    public init(transport: Transport, accessToken: String) {
        self.transport = transport
            .checkingStatusCodes()
            .authenticated(withBearerToken: accessToken)
    }

    public func fetchVideoPictures(videoURL: URL) async throws -> VimeoPictures {
        let (data, _) = try await transport
            .addingJSONHeaders()
            .get(from: videoURL)

        try Task.checkCancellation()

        return try decoder.decode(
            VimeoVideoResponse.self,
            from: data
        )
        .pictures
    }
    
    public func loadThumbnail(url: URL) async throws -> UIImage {
        let (data, _) = try await transport.get(from: url)

        try Task.checkCancellation()

        guard let image = UIImage(data: data) 
        else { throw VimeoError.invalidImageData }

        return image
    }

}
