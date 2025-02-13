//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by  Александр  on 22.01.2023.
//

import UIKit

protocol MoviesLoading {
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
    
}

struct MoviesLoader: MoviesLoading {
    
    // MARK: - NetworkClient
    
    private let networkClient: NetworkClientRouting
    
    init(networkClient: NetworkClientRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularMovies/k_884qb0ed") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
}
