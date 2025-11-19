// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  OIDCAuthStateValidator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/11/25.
//

import Foundation
import AuthStateStorageClient
import AppAuth

public protocol OIDCAuthStateValidator {
	var isValid: Bool { get }
	func invalidate()
}

public final class LiveOIDCAuthStateValidator<Storage: AuthStateStorageClient>: OIDCAuthStateValidator where Storage.AuthState == OIDAuthState {

	private let tokenStorage: Storage
	private let clientID: String

	public init(
		tokenStorage: Storage,
		clientID: String
	) {
		self.tokenStorage = tokenStorage
		self.clientID = clientID
	}

	/// Validates the authentication state against the expected client ID.
	///
	/// Returns `true` if the auth state is valid and matches the expected client ID, `false` otherwise.
	public var isValid: Bool {
		guard let authState = tokenStorage.state else {
			return true
		}

		return validateAuthState(authState, expectedClientID: clientID)
	}

	/// Invalidates and clears the stored authentication state.
	public func invalidate() {
		tokenStorage.state = nil
	}
}

private extension LiveOIDCAuthStateValidator {

	/// Validates whether the current authentication state matches the expected client ID.
	///
	/// - Parameters:
	///   - authState: The current `OIDAuthState` to validate.
	///   - expectedClientID: The client ID that the auth state should match.
	/// - Returns: `true` if the client IDs match, `false` otherwise.
	func validateAuthState(
		_ authState: OIDAuthState,
		expectedClientID: String
	) -> Bool {
		// Prefer the most recent client ID (from token response if available)
		let currentClientID = authState.lastTokenResponse?.request.clientID
		?? authState.lastAuthorizationResponse.request.clientID

		return currentClientID == expectedClientID
	}
}

