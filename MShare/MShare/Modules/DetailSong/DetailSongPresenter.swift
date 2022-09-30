//
//  DetailSongPresenter.swift
//  MShare
//
//  Created by Bohdan Pokhidnia on 06.08.2022.
//

import Foundation

protocol DetailSongPresenterProtocol: AnyObject {
    var view: DetailSongViewProtocol? { get set }
    var interactor: DetailSongInteractorIntputProtocol? { get set }
    var router: DetailSongRouterProtocol? { get set }
    
    func viewDidLoad()
    func dismissAction()
}

final class DetailSongPresenter {
    var view: DetailSongViewProtocol?
    var interactor: DetailSongInteractorIntputProtocol?
    var router: DetailSongRouterProtocol?
}

// MARK: - DetailSongPresenterProtocol

extension DetailSongPresenter: DetailSongPresenterProtocol {
    
    func viewDidLoad() {
        interactor?.requestSong()
    }
    
    func dismissAction() {
        router?.dismissModule(view: view)
    }
    
}

// MARK: - DetailSongInteractorOutputProtocol

extension DetailSongPresenter: DetailSongInteractorOutputProtocol {
    
    func didLoadSong(_ song: DetailSongEntity) {
        view?.setupContent(with: song)
    }
    
}
