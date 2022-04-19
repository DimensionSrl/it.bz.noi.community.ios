//
//  AuthCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 19/04/22.
//

import UIKit
import Foundation
import Combine
import SafariServices
import AuthClient

let kAppAuthExampleAuthStateKey: String = "authState";


// MARK: - AuthCoordinator

final class AuthCoordinator: BaseNavigationCoordinator {
    
    var didFinishHandler: ((AuthCoordinator) -> Void)!
    
    private var mainVC: AuthWelcomeViewController!
    private var welcomeViewModel: WelcomeViewModel!
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var authClient = dependencyContainer.makeAuthClient()
    
    override func start(animated: Bool) {
        welcomeViewModel = dependencyContainer.makeWelcomeViewModel()
        welcomeViewModel.startLoginPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.goToLogin()
            }
            .store(in: &subscriptions)
        welcomeViewModel.startSignUpPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.goToSignUp()
            }
            .store(in: &subscriptions)
        
        mainVC = dependencyContainer
            .makeWelcomeViewController(viewModel: welcomeViewModel)
        navigationController.setViewControllers([mainVC], animated: animated)
    }
    
}

// MARK: Private APIs

private extension AuthCoordinator {
    
    func goToLogin() {
        authClient.accessToken()
            .sink { [weak self] completion in
                guard let self = self
                else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.handleAuthError(error)
                }
            } receiveValue: { [weak self] _ in
                guard let self = self
                else { return }
                
                self.didFinishHandler(self)
            }
            .store(in: &subscriptions)
    }
    
    func goToSignUp() {
        let safariVC = SFSafariViewController(
            url: URL(string: "https://auth.opendatahub.bz.it/auth/realms/noi/protocol/openid-connect/registrations?client_id=it.bz.noi.community&redirect_uri=https://noi.bz.it&response_type=code&scope=openid")!
        )
        navigationController.present(safariVC, animated: true)
    }
    
    func handleAuthError(_ error: Error) {
        switch error {
        case let userCanceledAuthorizationFlow as AuthError
            where userCanceledAuthorizationFlow == .userCanceledAuthorizationFlow:
            break
        default:
            navigationController.showError(error)
        }
    }
    
}
