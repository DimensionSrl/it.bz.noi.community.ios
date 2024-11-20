// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoVideoResponse.swift
//  
//
//  Created by Matteo Matassoni on 04/10/24.
//

import Foundation

public struct VimeoVideoResponse: Codable {

    public var pictures: VimeoPictures

}

public struct VimeoPictures: Codable {

    public var sizes: [Size]

    public struct Size: Codable {

        public var width: Double
        public var height: Double
        public var link: String
        public var linkWithPlayButton: String

        public var aspectRatio: Double {
            return Double(width) / Double(height)
        }

    }
}
