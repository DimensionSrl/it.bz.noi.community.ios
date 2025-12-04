// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AuthConstants.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 03/05/22.
//

import Foundation

enum AuthConstant {

	private static let NOIOAuth2BaseURL: URL = {
#if TESTINGMACHINE_OAUTH
		return URL(string: "https://auth.opendatahub.testingmachine.eu/auth/realms/noi-community/")!
#else
		return URL(string: "https://auth.opendatahub.com/auth/realms/noi-community/")!
#endif
	}()

	static let issuerURL: URL = {
		NOIOAuth2BaseURL
	}()

	static let clientID = "community-app"

	static let redirectURI = URL(string: "noi-community://oauth2redirect/login-callback")!

	static let endSessionURI = URL(string: "noi-community://oauth2redirect/end_session-callback")!

}
