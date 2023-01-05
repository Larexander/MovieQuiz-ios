//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by  Александр  on 02.01.2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didPresentAlert(alert: UIAlertController?)
}
