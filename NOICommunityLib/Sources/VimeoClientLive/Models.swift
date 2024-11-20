// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Models.swift
//
//
//  Created by Matteo Matassoni on 04/10/24.
//

import Foundation

// MARK: - Vimeo Response Structures

struct VimeoResponse: Codable {
    let video: Video
    let request: Request
}

struct Video: Codable {
    let title: String
    let thumbs: [String: String]
}

struct Request: Codable {
    let files: Files
}

struct Files: Codable {
    let progressive: [ProgressiveFile]
    let hls: HLS
}

struct ProgressiveFile: Codable {
    let quality: String
    let url: String
}

struct HLS: Codable {
    let cdns: [String: CDN]
}

struct CDN: Codable {
    let url: String
}
