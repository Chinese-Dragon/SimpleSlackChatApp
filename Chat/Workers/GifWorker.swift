import Foundation

struct GifWorker {
  var gifService: GifService
  
  func fetchRandomGif(tag: String, completionHandler: @escaping GifServiceFetchRandomCompletionHandler) {
    gifService.fetchRandomGif(tag: tag, completionHandler: completionHandler)
  }
}
