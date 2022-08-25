//
//  LinkPresenter.swift
//  MShare
//
//  Created by Bohdan Pokhidnia on 28.07.2022.
//

import Foundation

protocol LinkPresenterProtocol: AnyObject {
    var view: LinkViewProtocol? { get set }
    var interactor: LinkInteractorIntputProtocol? { get set }
    var router: LinkRouterProtocol? { get set }
    
    func viewDidAppear()
    func getSong(urlString: String)
}

final class LinkPresenter {
    var view: LinkViewProtocol?
    var interactor: LinkInteractorIntputProtocol?
    var router: LinkRouterProtocol?
}

// MARK: - LinkPresenterProtocol

extension LinkPresenter: LinkPresenterProtocol {
    
    func viewDidAppear() {
        interactor?.setupNotification()
    }
    
    func getSong(urlString: String) {
        interactor?.requestSong(urlString: urlString)
    }
    
}

// MARK: - LinkInteractorOutputProtocol

extension LinkPresenter: LinkInteractorOutputProtocol {
    
    func didCatchURL(_ urlString: String) {
        view?.setLink(urlString)
        
        interactor?.requestSong(urlString: urlString)
    }
    
    func didFetchSong(_ detailSong: DetailSongEntity) {
        router?.presentDetailSongScreen(from: view, for: detailSong)
    }
    
}
