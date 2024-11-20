// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoClient.swift
//  
//
//  Created by Matteo Matassoni on 04/10/24.
//

import Foundation
import class UIKit.UIImage

public enum VimeoError: Error {
    case invalidURL
    case invalidImageData
}

public protocol VimeoClient {

    func fetchVideoPictures(videoURL: URL) async throws -> VimeoPictures
    func loadThumbnail(url: URL) async throws -> UIImage

}

public extension VimeoClient {

    func fetchVideoData(videoID: String) async throws -> VimeoPictures {
        guard let videoURL = URL(string: "https://api.vimeo.com/videos/\(videoID)")
        else { throw VimeoError.invalidURL }

        return try await fetchVideoPictures(videoURL: videoURL)
    }

}
