//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by  Александр  on 27.12.2022.
//

import UIKit

struct AlertPresenter: AlertPresenterProtocol {
 
    weak var delegate: AlertPresenterDelegate?
    
    func present(alert: AlertModel) {
        let alertController = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: alert.buttonText,
                                   style: .default,
                                   handler: alert.completion)
        alertController.addAction(action)
        delegate?.didPresentAlert(alert: alertController)
    }
    
}
