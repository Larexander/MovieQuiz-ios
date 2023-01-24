import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private var alertPresenter: AlertPresenter?
    private var quizQuestion: QuizQuestion?
    private var questionFactory: QuestionFactory?
    private var statisticService: StatisticService?
    private var currentQuestionIndex = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    
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
        guard let question = question else { return }
        quizQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
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
    
    private func hideLoadingIndicator(){
          activityIndicator.isHidden = true
      }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
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
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    } 
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionsAmount - 1 {
            imageView.layer.borderWidth = 8
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
                self.imageView.layer.borderWidth = 0
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.present(alert: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
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
        guard let quizQuestion = quizQuestion else { return }
        let givenAnswer = true
        self.showAnswerResult(isCorrect: givenAnswer == quizQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let quizQuestion = quizQuestion else { return }
        let givenAnswer = false
        self.showAnswerResult(isCorrect: givenAnswer == quizQuestion.correctAnswer)
    }
    
}
