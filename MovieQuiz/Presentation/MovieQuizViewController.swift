import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
   
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private let presenter = MovieQuizPresenter()
    
    @IBOutlet internal weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        self.presenter.alertPresenter = AlertPresenter(delegate: self)
        self.presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: presenter)
        self.presenter.statisticService = StatisticServiceImplementation()
        self.presenter.questionFactory?.loadData()
        self.presenter.viewController = self
    }
    
    // MARK: - Alert Presenter Delegate
    
    func didPresentAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Internal Functions
    
    internal func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        questionLabel.text = step.question
    }
    
    internal func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            self.presenter.correctAnswers += 1
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
    
    internal func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
      }
    
    internal func showNetworkError(message: String) {
        hideLoadingIndicator()
        self.presenter.correctAnswers = 0
        self.presenter.restartGame()
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] _ in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.presenter.questionFactory?.loadData()
        })
            self.presenter.alertPresenter?.present(alert: alertModel)
    }
    
    // MARK: - Private Functions
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating() 
    }

    private func showNextQuestionOrResults() {
        self.presenter.showNextQuestionOrResults()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        self.presenter.yesButtonClicked()
     }
     
     @IBAction private func noButtonClicked(_ sender: UIButton) {
         self.presenter.noButtonClicked()
     }
    
}
