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
    internal var statisticService: StatisticService?
    internal var correctAnswers: Int = 0
    internal var questionFactory: QuestionFactory?
    internal var alertPresenter: AlertPresenter?
    private var currentQuestionIndex = 0
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
    func restartGame() {
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
    
    func showNextQuestionOrResults() {
        viewController?.imageView?.layer.borderWidth = 0
        if isLastQuestion() {
            viewController?.imageView?.layer.borderWidth = 8
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let gamesCount = statisticService?.gamesCount else { return }
            guard let bestGame = statisticService?.bestGame else { return }
            guard let totalAccuracy = statisticService?.totalAccuracy else { return }
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                        message: """
                                                 Ваш результат: \(correctAnswers)/\(questionsAmount)
                                                 Количество сыгранных квизов: \(gamesCount)
                                                 Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                                                 Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                                                 """,
                                        buttonText: "Сыграть еще раз",
                                        completion: { [weak self] _ in
                guard let self = self else { return }
                self.viewController?.imageView?.layer.borderWidth = 0
                self.correctAnswers = 0
                self.restartGame()
                self.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.present(alert: alertModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
}
