//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by  Александр  on 26.12.2022.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
