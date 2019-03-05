import Foundation

struct MessagesWorker {
  var messagesStore: MessagesStoreProtocal
  
  func fetchMessags(completionHandler: @escaping MessagesStoreFetchMessagesCompletionHandler) {
    messagesStore.fetchMessages(completionHandler: completionHandler)
  }
  
  func createMessage(_ message: Message, completionHandler: @escaping MessagesStoreCreateMessageCompletionHandler) {
    messagesStore.createMessage(message, completionHandler: completionHandler)
  }
  
  func createMockMessage(completionHandler: @escaping MessagesStoreCreateMessageCompletionHandler) {
    messagesStore.createMockMessage(completionHandler: completionHandler)
  }
}
