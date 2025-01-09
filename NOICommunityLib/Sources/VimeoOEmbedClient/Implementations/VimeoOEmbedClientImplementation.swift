//
//  File.swift
//  
//
//  Created by Camilla on 23/12/24.
//

import UIKit
import AVFoundation

public final class VimeoOEmbedClientImplementation: VimeoOEmbedClient {
    
    private struct VimeoResponse: Codable {
        let thumbnail_url_with_play_button: String
    }
    
    private let screenScale: CGFloat
    private let urlSession: URLSession
    
    /// Costruttore per `VideoOEmbedClientImplementation`
    /// - Parameters:
    ///   - screenScale: Scala dello schermo per calcolare la larghezza dell'immagine. Valore di default: `UIScreen.main.scale`
    ///   - urlSession: Istanza di `URLSession` per le richieste di rete. Valore di default: `URLSession.shared`
    public init(screenScale: CGFloat = UIScreen.main.scale, urlSession: URLSession = .shared) {
        self.screenScale = screenScale
        self.urlSession = urlSession
    }
    
    /// Generates a thumbnail from a `.m3u8` video URL of a vimeo video
    /// - Parameter m3u8URL: URL of the `.m3u8` video
    /// - Returns: URL of the thumbnail, if available
    public func generateThumbnail(from videoURL: URL) async -> URL? {
        do {
            let videoID = try extractVideoID(from: videoURL)
            let jsonURL = try getJsonURL(for: videoID)
            let thumbnailURL = try await fetchThumbnailURL(from: jsonURL)
            return thumbnailURL
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    /// Estrae l'ID video dall'URL `.m3u8` di un video Vimeo
    private func extractVideoID(from videoURL: URL) throws -> String {
        let pathComponents = videoURL.pathComponents
        guard let externalIndex = pathComponents.firstIndex(of: "external"),
              externalIndex + 1 < pathComponents.count else {
            throw ThumbnailError.invalidVideoURL
        }
        
        var videoID = pathComponents[externalIndex + 1]
        
        // Remove the `.m3u8` extension if present
        if let range = videoID.range(of: ".m3u8") {
            videoID.removeSubrange(range)
        }
        
        print("Extracted Video ID: \(videoID)")
        return videoID
    }
    
    /// Costruisce l'URL dell'API JSON per ottenere la miniatura
    private func getJsonURL(for videoID: String) throws -> URL {
        let vimeoURL = "https://vimeo.com/\(videoID)"
        guard let encodedVimeoURL = vimeoURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ThumbnailError.invalidVimeoURL
        }
        
        let imageWidth = Int(315 * screenScale)
        
        var components = URLComponents(string: "https://vimeo.com/api/oembed.json")
        components?.queryItems = [
            URLQueryItem(name: "url", value: encodedVimeoURL),
            URLQueryItem(name: "width", value: "\(imageWidth)")
        ]
        
        guard let apiURL = components?.url else {
            throw ThumbnailError.invalidAPIURL
        }
        
        print("Generated JSON API URL: \(apiURL)")
        return apiURL
    }
    
    /// Fa una richiesta all'API Vimeo per ottenere l'URL della miniatura
    private func fetchThumbnailURL(from apiURL: URL) async throws -> URL {
        let (data, response) = try await urlSession.data(from: apiURL)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ThumbnailError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let vimeoResponse = try decoder.decode(VimeoResponse.self, from: data)
        
        guard let thumbnailURL = URL(string: vimeoResponse.thumbnail_url_with_play_button) else {
            throw ThumbnailError.invalidThumbnailURL
        }
        
        return thumbnailURL
    }
}

enum ThumbnailError: Error {
    case invalidVideoURL
    case invalidVimeoURL
    case invalidAPIURL
    case invalidResponse
    case invalidThumbnailURL
}
