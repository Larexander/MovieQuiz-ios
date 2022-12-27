import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    private var alertPresenter: AlertPresenter = AlertPresenter()
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Question Factory Delegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private Functions
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showNextQuestionOrResults() {
        guard currentQuestionIndex == questionsAmount - 1 else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
            return
        }
        imageView.layer.borderWidth = 0
              let alertModel: AlertModel = AlertModel(title: "Этот раунд окончен!", message: "Ваш результат: \(correctAnswers) из 10", buttonText: "Сыграть ещё раз", completion: { [weak self] in
                  guard let self = self else {return}
                  self.currentQuestionIndex = 0
                  self.correctAnswers = 0
                  self.questionFactory?.requestNextQuestion()
              })
              alertPresenter.present(alert: alertModel, presentingViewController: self)
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
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        self.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        self.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
