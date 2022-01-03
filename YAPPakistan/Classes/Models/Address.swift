
import Foundation

struct Address: Codable {
	let creationDate: String?
	let createdBy: String?
	let updatedDate: String?
	let updatedBy: String?
	let addressType: String?
	let accountUuid: String?
	let city: String?
	let country: String?
	let postalCode: String?
	let address1: String?
	let address2: String?
	let longitude: Double?
	let latitude: Double?
	let active: Bool?
	let uuid: String?
	let updatedOn: String?

	enum CodingKeys: String, CodingKey {

		case creationDate = "creationDate"
		case createdBy = "createdBy"
		case updatedDate = "updatedDate"
		case updatedBy = "updatedBy"
		case addressType = "addressType"
		case accountUuid = "accountUuid"
		case city = "city"
		case country = "country"
		case postalCode = "postalCode"
		case address1 = "address1"
		case address2 = "address2"
		case longitude = "longitude"
		case latitude = "latitude"
		case active = "active"
		case uuid = "uuid"
		case updatedOn = "updatedOn"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		creationDate = try values.decodeIfPresent(String.self, forKey: .creationDate)
		createdBy = try values.decodeIfPresent(String.self, forKey: .createdBy)
		updatedDate = try values.decodeIfPresent(String.self, forKey: .updatedDate)
		updatedBy = try values.decodeIfPresent(String.self, forKey: .updatedBy)
		addressType = try values.decodeIfPresent(String.self, forKey: .addressType)
		accountUuid = try values.decodeIfPresent(String.self, forKey: .accountUuid)
		city = try values.decodeIfPresent(String.self, forKey: .city)
		country = try values.decodeIfPresent(String.self, forKey: .country)
		postalCode = try values.decodeIfPresent(String.self, forKey: .postalCode)
		address1 = try values.decodeIfPresent(String.self, forKey: .address1)
		address2 = try values.decodeIfPresent(String.self, forKey: .address2)
		longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
		latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
		active = try values.decodeIfPresent(Bool.self, forKey: .active)
		uuid = try values.decodeIfPresent(String.self, forKey: .uuid)
		updatedOn = try values.decodeIfPresent(String.self, forKey: .updatedOn)
	}

}
