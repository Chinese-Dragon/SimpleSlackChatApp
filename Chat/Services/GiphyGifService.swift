import Foundation
import GiphyCoreSDK

enum GifServiceResult<T> {
  case success(value: T)
  case failure(error: MessagesStoreError)
}

enum GifServiceError: Equatable, Error {
  case CannotFetch(String)
  case CannotCreate(String)
  case CannotUpdate(String)
  case CannotDelete(String)
}

typealias GifServiceFetchRandomCompletionHandler = (GifServiceResult<String>) -> Void

protocol GifService {
  func fetchRandomGif(tag: String, completionHandler: @escaping GifServiceFetchRandomCompletionHandler)
}

struct GiphyGifService: GifService {
  func fetchRandomGif(tag: String, completionHandler: @escaping GifServiceFetchRandomCompletionHandler) {
    
    GiphyCore.shared.random(tag) { (response, error) in
      DispatchQueue.main.async {
        if let error = error {
          completionHandler(GifServiceResult.failure(error: .CannotFetch(error.localizedDescription)))
        } else if let response = response, let url = response.data?.images?.fixedHeightDownsampled?.gifUrl {
          completionHandler(GifServiceResult.success(value: url))
        } else {
          completionHandler(GifServiceResult.failure(error: .CannotFetch("No Data Found")))
        }
      }
    }
    
  }
}
