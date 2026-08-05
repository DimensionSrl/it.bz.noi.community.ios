// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint+Tag.swift
//  EventTagsClient
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation
import Core

extension Endpoint {

	static func eventTagList() -> Endpoint {
		Self(path: "/v1/Tag") {
			URLQueryItem(
				name: "types",
				value: Tag.customTagging
			)

			URLQueryItem(
				name: "types",
				value: Tag.technologyFields
			)

			URLQueryItem(
				name: "fields",
				value: "Id,TagName,Types"
			)

			URLQueryItem(
				name: "pagesize",
				value: "0"
			)
		}
	}

}
