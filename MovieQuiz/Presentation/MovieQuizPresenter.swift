//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by  Александр  on 08.02.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    internal weak var viewController: MovieQuizViewController?
    internal let questionsAmount: Int = 10
    internal var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
        func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
        
        func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
    func yesButtonClicked() {
         didAnswer(isYes: true)
     }
     
     func noButtonClicked() {
         didAnswer(isYes: false)
     }
     
     private func didAnswer(isYes: Bool) {
         guard let currentQuestion = currentQuestion else {
             return
         }
         
         let givenAnswer = isYes
         
         viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
     }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
}
