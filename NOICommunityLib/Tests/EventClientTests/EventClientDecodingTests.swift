// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventClientDecodingTests.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/08/26.
//

import XCTest

@testable import EventClient

final class EventClientDecodingTests: XCTestCase {

	private let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()

		jsonDecoder.dateDecodingStrategy = .custom { decoder in
			let container = try decoder.singleValueContainer()
			let dateStr = try container.decode(String.self)

			let dateFormatter = DateFormatter()
			dateFormatter.calendar = Calendar(identifier: .iso8601)
			dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")
			dateFormatter.locale = Locale(identifier: "en_US_POSIX")

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Cannot decode date string \(dateStr)"
			)
		}

		jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
		return jsonDecoder
	}()

	private func fixtureData(_ name: String) throws -> Data {
		let url = try XCTUnwrap(
			Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")
		)
		return try Data(contentsOf: url)
	}

	func testDecodeSingleEvent() throws {
		let data = try fixtureData("event")
		let event = try jsonDecoder.decode(RemoteEvent.self, from: data)

		XCTAssertEqual(event.id, "urn:event:noi:0cc8a97a-fce1-41e3-b03f-96a4bfbccf03")
		XCTAssertEqual(event.detail?["en"]?.title, "Digital Community Meeting: New labs, exciting projects: updates from the Digital Community")
		XCTAssertEqual(event.organizerInfos?["en"]?.companyName, "NOI")
		XCTAssertEqual(event.venueIds, ["urn:venue:noi:6b3f0a14-3c5b-5d09-81f3-3ebe5b7885ea"])
		XCTAssertEqual(
			event.eventUrls?.first { $0.type == "default" }?.url?["en"],
			"https://registration.noi.bz.it/event/registration?id=Digital_Community_Meeting3580533219"
		)
		let imageUrl = event.imageGallery?.compactMap { $0 }.first?.imageUrl
		XCTAssertEqual(imageUrl, "https://tourism.images.opendatahub.com/api/Image/GetImage?imageurl=f607966d-561e-42d3-864d-6b8840844626.jpg")
	}

	func testDecodeEventListResponse() throws {
		let data = try fixtureData("event_list")
		let response = try jsonDecoder.decode(EventListResponse.self, from: data)

		XCTAssertGreaterThan(response.totalResults, 0)
		XCTAssertFalse(response.items.isEmpty)
	}

	func testDecodeVenueListResponse() throws {
		let data = try fixtureData("venue_list")
		let response = try jsonDecoder.decode(VenueListResponse.self, from: data)

		XCTAssertEqual(response.totalResults, 1)
		let venue = try XCTUnwrap(response.items.first)
		XCTAssertEqual(venue.id, "urn:venue:noi:6b3f0a14-3c5b-5d09-81f3-3ebe5b7885ea")
		XCTAssertEqual(venue.detail?["en"]?.title, "NOI Techpark")
	}

}
