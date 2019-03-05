import UIKit

protocol ChatBusinessLogic {
  var currentUser: User { get }
  
  func fetchMessages(request: Chat.FetchMessages.Request)
  func createMessage(request: Chat.CreateMessage.Request)
  func createMockMessage(request: Chat.CreateMessage.MockRequest)
}

protocol ChatDataStore {
  var messages: [Message]? { get }
  var currentUser: User { get }
}

class ChatInteractor: ChatBusinessLogic, ChatDataStore {
  var presenter: ChatPresentationLogic?
  var messageWorker = MessagesWorker(messagesStore: MessagesMemStore())
  var gifWorker = GifWorker(gifService: GiphyGifService())
  var currentUser: User = User(userId: "666", avatarName: "avatar0", username: "Marko")
  var messages: [Message]?
  
  // MARK: Fetch Messages
  
  func fetchMessages(request: Chat.FetchMessages.Request) {
    messageWorker.fetchMessags { [weak self] (result) in
      var response: Chat.FetchMessages.Response!
      
      switch result {
      case .success(let messages):
        self?.messages = messages
        response = Chat.FetchMessages.Response(messages: messages)
      case .failure(_):
        response = Chat.FetchMessages.Response(messages: [])
      }
      
      self?.presenter?.presentMessages(response: response)
    }
  }
  
  // MARK: Create Message
  
  func createMessage(request: Chat.CreateMessage.Request) {
    let messageContent = request.messageContent
    
    if isGiphyRequest(message: messageContent) {
      let tag = messageContent.deletingPrefix("/giphy")
      gifWorker.fetchRandomGif(tag: tag, completionHandler: handleFetchGifResult)
    } else {
      createMessage(contentType: .text(messageContent))
    }
  }
  
  // MARK: Create Mock Message
  
  func createMockMessage(request: Chat.CreateMessage.MockRequest) {
    messageWorker.createMockMessage { [weak self] (result) in
      self?.handleCreateMessageResult(result)
    }
  }
  
  // MARK: Helpers
  
  private func createMessage(contentType: Message.contentType) {
    var newMessage: Message!
    
    if case let Message.contentType.photo(urlStr) = contentType {
      newMessage = Message(id: "dummyId", user: currentUser, timeStamp: Date(), content: .photo(urlStr: urlStr))
    } else if case let Message.contentType.text(textMessage) = contentType {
      newMessage = Message(id: "dummyId", user: currentUser, timeStamp: Date(), content: .text(textMessage))
    }
    
    messageWorker.createMessage(newMessage, completionHandler: handleCreateMessageResult)
  }
  
  private func handleCreateMessageResult(_ result: MessagesStoreResult<Message>) {
    var response: Chat.CreateMessage.Response!
    
    switch result {
    case .success(let message):
      let shouldGroup = (messages?.last?.user ?? nil) == message.user
      response = Chat.CreateMessage.Response(message: message, error: nil, shouldGroup: shouldGroup)
      messages?.append(message)
    case .failure(let error):
      response = Chat.CreateMessage.Response(message: nil, error: error, shouldGroup: false)
    }
    
    presenter?.presentMessage(response: response)
  }
  
  private func handleFetchGifResult(_ result: GifServiceResult<String>) {
    switch result {
    case .success(let gifUrl):
      createMessage(contentType: .photo(urlStr: gifUrl))
    case .failure(let error):
      let response = Chat.CreateMessage.Response(message: nil, error: error, shouldGroup: false)
      presenter?.presentMessage(response: response)
    }
  }
  
  private func isGiphyRequest(message: String) -> Bool {
    return message.hasPrefix("/giphy")
  }
}
