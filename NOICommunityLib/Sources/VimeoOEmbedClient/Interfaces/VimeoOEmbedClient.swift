//
//  File.swift
//  
//
//  Created by Camilla on 23/12/24.
//


import Foundation

public protocol VimeoOEmbedClient {
    func generateThumbnail(from videoURL: URL) async -> URL? 
}
