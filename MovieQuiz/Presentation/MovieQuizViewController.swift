import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
   
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private let presenter = MovieQuizPresenter()
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactory?
    private var statisticService: StatisticService?
    private var correctAnswers: Int = 0
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
    }
    
    // MARK: - Alert Presenter Delegate
    
    func didPresentAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Question Factory Delegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private Functions
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating() 
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
      }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        self.correctAnswers = 0
        self.presenter.resetQuestionIndex()
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] _ in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        })
        alertPresenter?.present(alert: alertModel)
    }
    
    internal func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if presenter.isLastQuestion() {
            imageView.layer.borderWidth = 8
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            guard let gamesCount = statisticService?.gamesCount else { return }
            guard let bestGame = statisticService?.bestGame else { return }
            guard let totalAccuracy = statisticService?.totalAccuracy else { return }
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                        message: """
                                                 Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                                                 Количество сыгранных квизов: \(gamesCount)
                                                 Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                                                 Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                                                 """,
                                        buttonText: "Сыграть еще раз",
                                        completion: { [weak self] _ in
                guard let self = self else { return }
                self.imageView.layer.borderWidth = 0
                self.correctAnswers = 0
                self.presenter.resetQuestionIndex()
                self.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.present(alert: alertModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    internal func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        self.noButton.isEnabled = false
        self.yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(named: "YP Green (iOS)")?.cgColor : UIColor(named: "YP Red (iOS)")?.cgColor
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
         presenter.yesButtonClicked()
     }
     
     @IBAction private func noButtonClicked(_ sender: UIButton) {
         presenter.noButtonClicked()
     }
    
}
