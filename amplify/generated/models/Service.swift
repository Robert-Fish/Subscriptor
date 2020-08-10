// swiftlint:disable all
import Amplify
import Foundation

public struct Service: Model {
  public let id: String
  public var title: String
  public var price: Double
  public var category: String
  public var purchaseDate: String
  
  public init(id: String = UUID().uuidString,
      title: String,
      price: Double,
      category: String,
      purchaseDate: String) {
      self.id = id
      self.title = title
      self.price = price
      self.category = category
      self.purchaseDate = purchaseDate
  }
}

extension Service: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
    }
}
