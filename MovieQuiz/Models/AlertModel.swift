//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by  Александр  on 27.12.2022.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: ((UIAlertAction) -> Void)?
}
