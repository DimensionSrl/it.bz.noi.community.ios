// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoVideo+VimeoResponse.swift
//
//
//  Created by Matteo Matassoni on 04/10/24.
//

import Foundation
import VimeoClient

extension VimeoVideo {

    init(from response: VimeoResponse) throws {
        let videoURLs: [VimeoVideoQuality: URL] = {
            var result: [VimeoVideoQuality: URL]

            result = Dictionary(
                uniqueKeysWithValues: response
                    .request
                    .files
                    .progressive
                    .compactMap { file in
                        guard let quality = VimeoVideoQuality(rawValue: file.quality),
                              let url = URL(string: file.url)
                        else { return nil }

                        return (quality, url)
                    }
            )

            if result.isEmpty,
               let hlsURL = response.request.files.hls.cdns.values.first?.url,
               let url = URL(string: hlsURL) {
                result[.quality1080p] = url
                result[.qualityUnknown] = url
            }

            return result
        }()

        guard !videoURLs.isEmpty
        else { throw VimeoExtractorError.noVideoURLFound }

        let title = response.video.title

        let thumbnailURLs: [VimeoThumbnailQuality: URL] = Dictionary(
            uniqueKeysWithValues: response
                .video
                .thumbs
                .compactMap { key, value in
                    guard let quality = VimeoThumbnailQuality(rawValue: key),
                          let url = URL(string: value)
                    else { return nil }

                    return (quality, url)
                }
        )

        self.init(
            title: title,
            thumbnailURLs: thumbnailURLs,
            videoURLs: videoURLs
        )
    }

}
