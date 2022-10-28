//
//  DetailSongEntity.swift
//  MShare
//
//  Created by Bohdan Pokhidnia on 06.08.2022.
//

import UIKit

struct DetailSongEntity {
    let songName: String
    let artistName: String
    let image: UIImage?
    let sourceURL: String
    let services: [MediaService]
}
