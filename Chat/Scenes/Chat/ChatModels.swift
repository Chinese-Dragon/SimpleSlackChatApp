import UIKit

enum Chat {
  
  enum FetchMessages {
    
    struct Request {}
    
    struct Response {
      var messages: [Message]
    }
    
    struct ViewModel {
      
      enum DisplayedMessage {
        case initialMessage(avatar: String, username: String, timestamp: String, message: Message.contentType)
        case grouppedMessage(message: Message.contentType)
      }
      
      var displayedMessages: [DisplayedMessage]
    }
  }
  
  enum CreateMessage {
    
    struct MockRequest {}
    
    struct Request {
      var messageContent: String
    }
    
    struct Response {
      var message: Message?
      var error: MessagesStoreError?
      var shouldGroup = false
    }
    
    struct ViewModel {
      var displayedMessage: Chat.FetchMessages.ViewModel.DisplayedMessage?
      var error: MessagesStoreError?
    }
  }
}
