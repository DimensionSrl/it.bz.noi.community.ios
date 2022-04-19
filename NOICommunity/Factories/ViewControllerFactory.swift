//
//  ViewControllerFactory.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation

protocol ViewControllerFactory {
    
    func makeEventListViewController() -> EventListViewController
    
    func makeEventFiltersViewController(
        viewModel: EventFiltersViewModel
    ) -> EventFiltersViewController
    
    func makeWelcomeViewController(
        viewModel: WelcomeViewModel
    ) -> AuthWelcomeViewController
}
