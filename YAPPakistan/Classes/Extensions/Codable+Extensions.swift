//
//  Codable+Extensions.swift
//  YAPPakistan
//
//  Created by Umair  on 15/02/2022.
//

extension Decodable {
  init(from: Any) throws {
      let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
      let decoder = JSONDecoder()
      self = try decoder.decode(Self.self, from: data)
  }
}

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
