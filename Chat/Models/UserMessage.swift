import Foundation

struct User: Equatable {
  var userId: String
  var avatarName: String
  var username: String
}

struct Message: Comparable {
  
  enum contentType {
    case text(String)
    case photo(urlStr: String)
  }
  
  var id: String
  var user: User
  var timeStamp: Date
  var content: contentType
  
}

func ==(lhs: Message, rhs: Message) -> Bool {
  return lhs.id == rhs.id
}

func <(lhs: Message, rhs: Message) -> Bool {
  return lhs.timeStamp < rhs.timeStamp
}
