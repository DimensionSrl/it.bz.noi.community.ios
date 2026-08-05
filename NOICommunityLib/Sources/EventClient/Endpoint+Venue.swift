// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint+Venue.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation
import Core

// MARK: - Endpoint+Venue

extension Endpoint {

	static func venues(
		ids: [String],
		language: String? = nil
	) -> Endpoint {
		Self(path: "/v1/Venue") {
			URLQueryItem(
				name: "idlist",
				value: ids.joined(separator: ",")
			)

			if let language {
				URLQueryItem(
					name: "language",
					value: language
				)
			}

			URLQueryItem(
				name: "fields",
				value: "Id,Detail"
			)

			URLQueryItem(
				name: "pagesize",
				value: "0"
			)

			URLQueryItem(
				name: "removenullvalues",
				value: "true"
			)
		}
	}

}
