import Foundation

enum MessagesStoreResult<T> {
  case success(value: T)
  case failure(error: MessagesStoreError)
}

enum MessagesStoreError: Equatable, Error {
  case CannotFetch(String)
  case CannotCreate(String)
  case CannotUpdate(String)
  case CannotDelete(String)
}

typealias MessagesStoreFetchMessagesCompletionHandler = (MessagesStoreResult<[Message]>) -> Void
typealias MessagesStoreCreateMessageCompletionHandler = (MessagesStoreResult<Message>) -> Void

protocol MessagesStoreProtocal {
  func fetchMessages(completionHandler: @escaping MessagesStoreFetchMessagesCompletionHandler)
  func createMessage(_ message: Message, completionHandler: @escaping MessagesStoreCreateMessageCompletionHandler)
  func createMockMessage(completionHandler: @escaping MessagesStoreCreateMessageCompletionHandler)
}

protocol MessagesStoreUtilityProtocol {}

extension MessagesStoreUtilityProtocol {
  func generateRandomString(length: Int = 10) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0...length-1).map{ _ in letters.randomElement()! })
  }
  
  func generateRandomAvatarName() -> String {
    return "avatar\(Int.random(in: 0...8))"
  }
  
  func generateRandomTextMessage() -> String {
    let fakeMessageCount = MessagesMemStore.messageContents.count
    return MessagesMemStore.messageContents[Int.random(in: 0..<fakeMessageCount)]
  }
}

struct MessagesMemStore: MessagesStoreProtocal, MessagesStoreUtilityProtocol {
  
  func fetchMessages(completionHandler: @escaping MessagesStoreFetchMessagesCompletionHandler) {
    DispatchQueue.main.async {
      completionHandler(MessagesStoreResult.success(value: type(of: self).messages))
    }
  }
  
  func createMessage(_ message: Message, completionHandler: @escaping MessagesStoreCreateMessageCompletionHandler) {
    var newMessage = message
    newMessage.id = generateRandomString()
    type(of: self).messages.append(newMessage)
    DispatchQueue.main.async {
      completionHandler(MessagesStoreResult.success(value: newMessage))
    }
  }
  
  func createMockMessage(completionHandler: @escaping MessagesStoreCreateMessageCompletionHandler) {
    let randomUser = User(userId: generateRandomString(), avatarName: generateRandomAvatarName(), username: generateRandomString(length: 6))
    let randomMessage = Message(id: generateRandomString(), user: randomUser, timeStamp: Date(), content: .text(generateRandomTextMessage()))
    type(of: self).messages.append(randomMessage)
    DispatchQueue.main.async {
      completionHandler(MessagesStoreResult.success(value: randomMessage))
    }
  }
}

extension MessagesMemStore {
  
  // MARK: - Mock Data
  static var messageContents: [String] = [
    "The standard Lorem Ipsum passage, used since the 1500s Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
    "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem",
    "Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?",
    "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful.",
    "Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure.",
    "To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?",
    "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga.",
    "Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. ",
    "Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.",
    "On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue"
  ]
  
  static var messages = [
    Message(
      id: "1",
      user: User(
        userId: "a1",
        avatarName: "avatar1",
        username: "a1"
      ),
      timeStamp: Date(),
      content: Message.contentType.text("Hey this looks good")),
    Message(
      id: "2",
      user: User(
        userId: "a2",
        avatarName: "avatar2",
        username: "a2"
      ),
      timeStamp: Date(),
      content: Message.contentType.text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat")),
    Message(
      id: "3",
      user: User(
        userId: "a3",
        avatarName: "avatar3",
        username: "a3"
      ),
      timeStamp: Date(),
      content: Message.contentType.text("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")),
    Message(
      id: "4",
      user: User(
        userId: "a3",
        avatarName: "avatar3",
        username: "a3"
      ),
      timeStamp: Date(),
      content: Message.contentType.text("I shoud be groupped together"))
  ]
}
