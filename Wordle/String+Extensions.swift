import Foundation
import UIKit

extension StringProtocol {
  subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
}

extension String {
  var isValidWord: Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: self.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: self, range: range, startingAt: 0, wrap: false, language: "en")
    return misspelledRange.location == NSNotFound
  }
}

extension String: Identifiable {
  public var id: String {
    self
  }
}

extension Character: Identifiable {
  public var id: Character {
    self
  }
}

extension Array: Identifiable where Element == Character {
  public var id: String {
    self.map(String.init).joined()
  }
}
