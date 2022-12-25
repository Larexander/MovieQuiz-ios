//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by  Александр  on 25.12.2022.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}

