//
//  DetailSongView.swift
//  MShare
//
//  Created by Bohdan Pokhidnia on 06.08.2022.
//

import UIKit

protocol DetailSongViewProtocol: AnyObject {
    var presenter: DetailSongPresenterProtocol? { get set }
    var viewController: UIViewController { get }
    
    func setupContent(withState state: DetailSongEntity, withHorizontalActionMenuItem horizontalActionMenuItem: [HorizontalActionMenuItem])
    func setCoverAnimation(animationState: CoverViewAnimation, completion: (() -> Void)?)
    func showCopiedToast()
    func showUnavailableToast()
}

final class DetailSongView: ViewController<DetailSongContentView> {
    
    var presenter: DetailSongPresenterProtocol?
    
    var viewController: UIViewController {
        return self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupActionsHandler()
        presenter?.viewDidLoad()
    }

}

// MARK: - Setup

private extension DetailSongView {
    
    func setupNavigationBar() {
        title = "Share"
        UINavigationBar.configure(style: .transcelent)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapDismissBarButton))
    }
    
    func setupViews() {
        contentView.horizontalActionMenuView.delegare = self
    }
    
    func setupActionsHandler() {
        contentView.coverView.whenTap = { [unowned self] in
            presenter?.copyCoverToBuffer(fromView: self.contentView.coverView)
        }
    }
    
}

// MARK: - User interactions

private extension DetailSongView {
    
    @objc
    func didTapDismissBarButton() {
        presenter?.dismissAction()
    }
    
}

// MARK: - DetailSongViewProtocol

extension DetailSongView: DetailSongViewProtocol {
    
    func setupContent(withState state: DetailSongEntity, withHorizontalActionMenuItem horizontalActionMenuItem: [HorizontalActionMenuItem]) {
        contentView
            .set(state: state)
            .make {
                $0.horizontalActionMenuView.set(menuItems: horizontalActionMenuItem)
            }
    }
    
    func setCoverAnimation(animationState: CoverViewAnimation, completion: (() -> Void)?) {
        contentView.set(animationState: animationState, completion: completion)
    }
    
    func showCopiedToast() {
        contentView.copiedToast.show(haptic: .success)
    }
    
    func showUnavailableToast() {
        contentView.unvailableToast.show(haptic: .warning)
    }
    
}

// MARK: - HorizontalActionMenuDelegate

extension DetailSongView: HorizontalActionMenuDelegate {
    
    func didTapActionItem(_ horizontalActionMenuView: HorizontalActionMenuView,
                          action: HorizontalMenuAction,
                          available: Bool,
                          didSelectItemAt indexPath: IndexPath) {
        guard available else {
            showUnavailableToast()
            return
        }
        
        switch action {
        case .shareAppleMusicLink, .shareSpotifyLink, .shareYouTubeMusicLink:
            stopLoadingAnimation(for: horizontalActionMenuView)
            
        case .shareCover:
            guard let coverImage = contentView.makeImage() else { return }
            
            presenter?.shareCover(cover: coverImage) {
                horizontalActionMenuView.set(animationStyle: .normal)
            }
        case .saveToFavorite:
            presenter?.saveToFavorite()
            stopLoadingAnimation(for: horizontalActionMenuView)
        }
    }
    
}

// MARK: - Private Methods

private extension DetailSongView {
    
    func stopLoadingAnimation(for horizontalActionMenuView: HorizontalActionMenuView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            horizontalActionMenuView.set(animationStyle: .normal)
        }
    }
    
}
