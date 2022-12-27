//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by  Александр  on 27.12.2022.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
