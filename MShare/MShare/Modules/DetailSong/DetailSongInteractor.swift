//
//  DetailSongInteractor.swift
//  MShare
//
//  Created by Bohdan Pokhidnia on 06.08.2022.
//

import UIKit
import Photos

protocol DetailSongInteractorInputProtocol {
    var presenter: DetailSongInteractorOutputProtocol? { get set }
    
    func requestMedia()
    func requestShareMedia(for destinationService: String)
    func copyImageToBuffer(_ image: UIImage?)
    func saveToDatabase()
    func hasMediaInDatabase()
    func requestAccessToGallery(_ image: UIImage, completion: (() -> Void)?)
}

protocol DetailSongInteractorOutputProtocol: AnyObject {
    func didLoadDetailMedia(_ detailMedia: DetailSongEntity)
    func didLoadShareMedia(_ shareMedia: ShareMediaResponse)
    func didCatchError(_ error: NetworkError)
    func hasMediaInDatabase(_ isSaved: Bool)
    func didRequestedAccessToGallery(_ image: UIImage, completion: (() -> Void)?)
}

final class DetailSongInteractor {
    weak var presenter: DetailSongInteractorOutputProtocol?
    
    private let mediaResponse: MediaResponse
    private let cover: UIImage
    private let databaseManager: DatabaseManagerProtocol = DatabaseManager()
    private let networkService: NetworkServiceProtocol = NetworkService()
    
    init(mediaResponse: MediaResponse, cover: UIImage) {
        self.mediaResponse = mediaResponse
        self.cover = cover
    }
}

// MARK: - DetailSongInteractorInputProtocol

extension DetailSongInteractor: DetailSongInteractorInputProtocol {
    
    func requestMedia() {
        switch mediaResponse.mediaType {
        case .song:
            guard let song = mediaResponse.song else { return }
            let detailSong = DetailSongEntity(songName: song.songName,
                                              artistName: song.artistName,
                                              image: cover,
                                              sourceURL: song.songUrl,
                                              services: mediaResponse.services)
            
            
            presenter?.didLoadDetailMedia(detailSong)
            
            
        case .album:
            guard let album = mediaResponse.album else { return }
            let detailAlbum = DetailSongEntity(songName: album.albumName,
                                               artistName: album.artistName,
                                               image: cover,
                                               sourceURL: album.albumUrl,
                                               services: mediaResponse.services)
            
            presenter?.didLoadDetailMedia(detailAlbum)
        }
    }
    
    func requestShareMedia(for destinationService: String) {
        switch mediaResponse.mediaType {
        case .song:
            guard let song = mediaResponse.song else { return }
            
            networkService.request(endpoint: GetShareMedia(originService: song.serviceType,
                                                           sourceId: song.songSourceId,
                                                           destinationService: destinationService))
            { [weak presenter] (response: ShareMediaResponse?, error) in
                guard error == nil else {
                    presenter?.didCatchError(error!)
                    return
                }
                
                guard let response else {
                    presenter?.didCatchError(.message("Without response"))
                    return
                }
                
                presenter?.didLoadShareMedia(response)
            }
            
        case .album:
            break
        }
    }
    
    func copyImageToBuffer(_ image: UIImage?) {
        UIPasteboard.general.image = image
    }
    
    func saveToDatabase() {
        guard let coverData = cover.pngData() else {
            print("[dev] error get png data from cover")
            return
        }
        
        let mediaModel = MediaModel(mediaResponse: mediaResponse, coverData: coverData)
        
        if let savedMediaModel = databaseManager.getObject(MediaModel.self, forPrimaryKey: mediaModel.sourceId) {
            databaseManager.delete(savedMediaModel) { (error) in
                guard error == nil else {
                    print("[dev] error: \(error)")
                    return
                }
            }
        } else {
            databaseManager.save(mediaModel) { (error) in
                if let error {
                    print("[dev] error: \(error.localizedDescription)")
                } else {
                    print("[dev] media success saved")
                }
            }
        }
    }
    
    func hasMediaInDatabase() {
        var mediaModel: MediaModel?
        
        switch mediaResponse.mediaType {
        case .song:
            guard let song = mediaResponse.song else { return }
            mediaModel = databaseManager.getObject(MediaModel.self, forPrimaryKey: song.songSourceId)
            
        case .album:
            guard let album = mediaResponse.album else { return }
            mediaModel = databaseManager.getObject(MediaModel.self, forPrimaryKey: album.albumSourceId)
        }
        
        let isSaved = mediaModel != nil
        presenter?.hasMediaInDatabase(isSaved)
    }
    
    func requestAccessToGallery(_ image: UIImage, completion: (() -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            print("[dev] we are authorized")
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    print("[dev] we give access to save in library")
                    
                default:
                    print("[dev] status requested to gallery: \(status)")
                }
            }
            
        default:
            print("[dev] we need say user open settings, status: \(status)")
        }
        
        presenter?.didRequestedAccessToGallery(image, completion: completion)
    }
    
}
