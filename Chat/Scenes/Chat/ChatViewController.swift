import UIKit
import Kingfisher

protocol ChatDisplayLogic: class {
  func displayMessages(viewModel: Chat.FetchMessages.ViewModel)
  func displayNewMessage(viewModel: Chat.CreateMessage.ViewModel)
}

class ChatViewController: UIViewController, ChatDisplayLogic {
  var interactor: ChatBusinessLogic?
  var router: (NSObjectProtocol & ChatRoutingLogic & ChatDataPassing)?

  // MARK: Object lifecycle
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: Setup
  
  private func setup() {
    let viewController = self
    let interactor = ChatInteractor()
    let presenter = ChatPresenter()
    let router = ChatRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Setup Views
  
  @IBOutlet weak var tableview: UITableView!
  @IBOutlet weak var inputViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var atButton: UIButton!
  @IBOutlet weak var slashButton: UIButton!
  @IBOutlet weak var attachmentButton: UIButton!
  @IBOutlet weak var galleryButton: UIButton!
  @IBOutlet weak var sendMessageButton: UIButton!
  @IBOutlet weak var expandInputBoxButton: UIButton!
  @IBOutlet weak var inputTextView: UITextView!
  
  var slackBarButton: UIBarButtonItem!
  var chatInfoBarButton: UIBarButtonItem!
  var searchBarButton: UIBarButtonItem!
  var profileBarButton: UIBarButtonItem!
  
  private func setUpViews() {
    tableview.rowHeight = UITableView.automaticDimension
    tableview.estimatedRowHeight = 70
    inputTextView.text = "Message #developers"
    inputTextView.textColor = UIColor.lightGray
    sendMessageButton.layer.borderColor = UIColor.lightGray.cgColor
    sendMessageButton.layer.borderWidth = 1.0
    sendMessageButton.layer.cornerRadius = 5.0
    sendMessageButton.layer.masksToBounds = true
    sendMessageButton.setTitleColor(UIColor.white, for: .normal)
    sendMessageButton.setTitleColor(UIColor.darkGray, for: .disabled)
    setUpBarButtons()
  }
  
  private func setUpBarButtons() {
    slackBarButton = UIBarButtonItem(
      image: UIImage(named: "slack"),
      style: .plain,
      target: self,
      action: #selector(barButtonPressed(_:)))
    
    let chatInfoButton = UIButton()
    chatInfoButton.setTitle("#developers", for: .normal)
    chatInfoButton.setTitleColor(UIColor.black, for: .normal)
    chatInfoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    chatInfoButton.setImage(UIImage(named: "down_arrow"), for: .normal)
    chatInfoButton.semanticContentAttribute = .forceRightToLeft
    chatInfoBarButton = UIBarButtonItem(customView: chatInfoButton)
    
    searchBarButton = UIBarButtonItem(
      barButtonSystemItem: .search,
      target: self,
      action: #selector(barButtonPressed(_:)))
    searchBarButton.tintColor = UIColor.black
    
    profileBarButton = UIBarButtonItem(
      image: UIImage(named: "profile"),
      style: .plain,
      target: self,
      action: #selector(barButtonPressed(_:)))
    profileBarButton.tintColor = UIColor.black
    
    self.navigationItem.leftBarButtonItems = [slackBarButton, chatInfoBarButton]
    self.navigationItem.rightBarButtonItems = [profileBarButton, searchBarButton]
  }
  
  @objc private func barButtonPressed(_ sender: UIBarButtonItem) {
    
  }
  
  @IBAction func buttonPressed(_ sender: UIButton) {
    if sender == sendMessageButton {
      createMessage()
      inputTextView.text.removeAll()
      textViewDidChange(inputTextView)
    }
  }
  
  // MARK: Handle Keyboard Events
  
  func setUpKeyboardEventObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func removeKeyboardEventObserver() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0 {
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    if self.view.frame.origin.y != 0 {
      self.view.frame.origin.y = 0
    }
  }
  
  // MARK: View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpViews()
    setUpKeyboardEventObserver()
    fetchMessages()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setUpKeyboardEventObserver()
    setUpMockMessageTimer()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardEventObserver()
    destroyMockTimer()
  }
  
  // MARK: Mock Messages Timer
  
  var mockMessageTimer: Timer!
  
  private func setUpMockMessageTimer() {
    mockMessageTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(createMockMessage), userInfo: nil, repeats: true)
  }
  
  private func destroyMockTimer() {
    mockMessageTimer.invalidate()
  }
  
  @objc private func createMockMessage() {
    let request = Chat.CreateMessage.MockRequest()
    interactor?.createMockMessage(request: request)
  }
  
  // MARK: Fetch Messages
  
  fileprivate var displayedMessages: [Chat.FetchMessages.ViewModel.DisplayedMessage] = []
  
  func fetchMessages() {
    let request = Chat.FetchMessages.Request()
    interactor?.fetchMessages(request: request)
  }
  
  // MARK: Create Message
  
  func createMessage() {
    let sanitizedInputText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !sanitizedInputText.isEmpty else { return }
    
    let request = Chat.CreateMessage.Request(messageContent: sanitizedInputText)
    interactor?.createMessage(request: request)
  }
  
  // MARK: Display Messages
  
  func displayMessages(viewModel: Chat.FetchMessages.ViewModel) {
    displayedMessages = viewModel.displayedMessages
    tableview.reloadData()
  }
  
  // MARK: Display New Message
  
  func displayNewMessage(viewModel: Chat.CreateMessage.ViewModel) {
    guard viewModel.error == nil else {
      // TODO: Show Error
      return
    }
    
    if let newDisplayedMessage = viewModel.displayedMessage {
      displayedMessages.append(newDisplayedMessage)
      let newIndexPath = IndexPath(row: displayedMessages.count - 1, section: 0)
      tableview.insertRows(at: [newIndexPath], with: .automatic)
      tableview.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
    }
  }
}

extension ChatViewController {
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedMessages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell!
    let displayedMessage = displayedMessages[indexPath.row]
    
    switch displayedMessage {
    case .grouppedMessage(let contentType):
      if case let Message.contentType.photo(urlStr) = contentType {
        cell = tableview.dequeueReusableCell(withIdentifier: GroupedPhotoMessageTableViewCell.identifier, for: indexPath)
        (cell as! GroupedPhotoMessageTableViewCell).photoMessage.kf.setImage(with: URL(string: urlStr))
      } else if case let Message.contentType.text(message) = contentType {
        cell = tableview.dequeueReusableCell(withIdentifier: GroupedTextMessageTableViewCell.identifider, for: indexPath)
        (cell as! GroupedTextMessageTableViewCell).message.text = message
      }
    case .initialMessage(let avatar, let username, let timestamp, let contentType):
      if case let Message.contentType.photo(urlStr) = contentType {
        cell = tableview.dequeueReusableCell(withIdentifier: ChatPhotoMessageTableViewCell.identifier, for: indexPath)
        (cell as! ChatPhotoMessageTableViewCell).avatar.image = UIImage(named: avatar)
        (cell as! ChatPhotoMessageTableViewCell).username.text = username
        (cell as! ChatPhotoMessageTableViewCell).timestamp.text = timestamp
        (cell as! ChatPhotoMessageTableViewCell).photoMessage.kf.setImage(with: URL(string: urlStr))
      } else if case let Message.contentType.text(message) = contentType {
        cell = tableview.dequeueReusableCell(withIdentifier: ChatTextMessageTableViewCell.identifier, for: indexPath)
        (cell as! ChatTextMessageTableViewCell).message.text = message
        (cell as! ChatTextMessageTableViewCell).avatar.image = UIImage(named: avatar)
        (cell as! ChatTextMessageTableViewCell).username.text = username
        (cell as! ChatTextMessageTableViewCell).timestamp.text = timestamp
      }
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ChatViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    if !textView.text.isEmpty {
      sendMessageButton.isEnabled = true
      sendMessageButton.backgroundColor = UIColor.blue
      adjustTextViewHeight()
    } else {
      sendMessageButton.isEnabled = false
      sendMessageButton.backgroundColor = UIColor.white
    }
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      inputTextView.text = "Message #developers"
      inputTextView.textColor = UIColor.lightGray
    }
  }
  
  private func adjustTextViewHeight() {
    let fixedWidth = inputTextView.frame.size.width
    let newSize = inputTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    self.inputViewHeightConstraint.constant = newSize.height
    self.view.layoutIfNeeded()
  }
}
