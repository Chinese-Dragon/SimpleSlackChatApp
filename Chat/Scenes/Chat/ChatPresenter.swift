import UIKit

protocol ChatPresentationLogic {
  func presentMessages(response: Chat.FetchMessages.Response)
  func presentMessage(response: Chat.CreateMessage.Response)
}

class ChatPresenter: ChatPresentationLogic {
  weak var viewController: ChatDisplayLogic?
  
  let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter
  }()
  
  // MARK: - Present Messages
  
  func presentMessages(response: Chat.FetchMessages.Response) {
    var displayedMessages: [Chat.FetchMessages.ViewModel.DisplayedMessage] = []
    
    var prevMessage: Message?
    for message in response.messages.sorted() {
      var displayedMessage: Chat.FetchMessages.ViewModel.DisplayedMessage!
      if let prevMsg = prevMessage, prevMsg.user == message.user {
        // groupped msg
        displayedMessage = Chat.FetchMessages.ViewModel.DisplayedMessage.grouppedMessage(message: message.content)
      } else {
        // initial
        displayedMessage = Chat.FetchMessages.ViewModel.DisplayedMessage.initialMessage(avatar: message.user.avatarName, username: message.user.username, timestamp: dateFormatter.string(from: message.timeStamp), message: message.content)
      }
      displayedMessages.append(displayedMessage)
      prevMessage = message
    }
    
    let viewModel = Chat.FetchMessages.ViewModel(displayedMessages: displayedMessages)
    viewController?.displayMessages(viewModel: viewModel)
  }
  
  // MARK: - Present Message
  
  func presentMessage(response: Chat.CreateMessage.Response) {
    guard response.error == nil else {
      let viewModel = Chat.CreateMessage.ViewModel(displayedMessage: nil, error: response.error!)
      viewController?.displayNewMessage(viewModel: viewModel)
      return
    }
    
    var displayedMessage: Chat.FetchMessages.ViewModel.DisplayedMessage?
    
    if let newMessage = response.message {
      if response.shouldGroup {
        displayedMessage = Chat.FetchMessages.ViewModel.DisplayedMessage.grouppedMessage(message: newMessage.content)
      } else {
        displayedMessage = Chat.FetchMessages.ViewModel.DisplayedMessage.initialMessage(avatar: newMessage.user.avatarName, username: newMessage.user.username, timestamp: dateFormatter.string(from: newMessage.timeStamp), message: newMessage.content)
      }
      
      let viewModel = Chat.CreateMessage.ViewModel(displayedMessage: displayedMessage, error: nil)
      viewController?.displayNewMessage(viewModel: viewModel)
    }
  }
}
