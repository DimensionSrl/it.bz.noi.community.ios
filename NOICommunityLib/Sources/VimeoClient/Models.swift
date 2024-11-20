// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//
//  Models.swift
//  
//
//  Created by Matteo Matassoni on 04/10/24.
//

import Foundation

public struct VimeoVideo {

    public var title: String
    public var thumbnailURLs: [VimeoThumbnailQuality: URL]
    public var videoURLs: [VimeoVideoQuality: URL]

    public init(
        title: String,
        thumbnailURLs: [VimeoThumbnailQuality: URL],
        videoURLs: [VimeoVideoQuality: URL]
    ) {
        self.title = title
        self.thumbnailURLs = thumbnailURLs
        self.videoURLs = videoURLs
    }

}

public enum VimeoVideoQuality: String, Codable {
    case quality360p = "360p"
    case quality540p = "540p"
    case quality640p = "640p"
    case quality720p = "720p"
    case quality960p = "960p"
    case quality1080p = "1080p"
    case qualityUnknown = "unknown"
}

public enum VimeoThumbnailQuality: String, Codable {
    case qualityBase = "base"
    case quality640 = "640"
    case quality960 = "960"
    case quality1280 = "1280"
    case quality1920 = "1920"
    case qualityUnknown = "unknown"
}
