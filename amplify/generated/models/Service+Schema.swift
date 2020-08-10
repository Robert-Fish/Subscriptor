// swiftlint:disable all
import Amplify
import Foundation

extension Service {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case title
    case price
    case category
    case purchaseDate
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let service = Service.keys
    
    model.pluralName = "Services"
    
    model.fields(
      .id(),
      .field(service.title, is: .required, ofType: .string),
      .field(service.price, is: .required, ofType: .double),
      .field(service.category, is: .required, ofType: .string),
      .field(service.purchaseDate, is: .required, ofType: .string)
    )
    }
}