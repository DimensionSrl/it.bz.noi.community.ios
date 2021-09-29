//
//  MoreMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/09/21.
//

import UIKit

// MARK: - MoreViewModel

final class MoreViewModel {
    struct Entry: Hashable, CaseIterable {
        static var allCases: [Entry] = [
            .bookRoom,
            .onboarding,
            .feedbacks
        ]

        let localizedTitle: String
        let url: URL?

        static let bookRoom = Self(
            localizedTitle: .localized("room_booking"),
            url: .roomBooking
        )
        static let onboarding = Self(
            localizedTitle: .localized("more_item_onboarding"),
            url: .onboarding
        )
        static let feedbacks = Self(
            localizedTitle: .localized("more_item_feedback"),
            url: .feedbacks
        )
    }
}

// MARK: - MoreMainViewController

final class MoreMainViewController: UICollectionViewController {

    typealias Entry = MoreViewModel.Entry
    private var dataSource: UICollectionViewDiffableDataSource<Section, Entry>! = nil

    var didSelectHandler: ((Entry) -> Void)?

    init() {
        super.init(collectionViewLayout: Self.createLayout())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    @available(*, unavailable)
    override init(
        collectionViewLayout layout: UICollectionViewLayout
    ) {
        fatalError("\(#function) not implemented")
    }

    @available(*, unavailable)
    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        fatalError("\(#function) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Private APIs

private extension MoreMainViewController {
    enum Section: Hashable {
        case main
    }

    static func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .secondaryBackgroundColor
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Entry> { cell, _, entry in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = entry.localizedTitle
            cell.contentConfiguration = contentConfiguration

            cell.accessories = [.disclosureIndicator()]
        }

        dataSource = .init(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Entry>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Entry.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: UICollectionViewDelegate

extension MoreMainViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedEntry = dataSource.itemIdentifier(for: indexPath)!
        didSelectHandler?(selectedEntry)
    }
}