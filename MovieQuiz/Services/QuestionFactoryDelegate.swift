//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by  Александр  on 26.12.2022.
//

import Foundation

protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: CurrentQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error) 
}
