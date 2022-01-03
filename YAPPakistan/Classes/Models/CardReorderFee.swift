
import Foundation
struct CardReorderFee: Codable {
	let feeType: String?
	let amount: Double?
	let vat: Double?
	let totalFee: Double?
	let displayOnly: Bool?
	let tierRateDTOList: [TierRateDTOList]?

	enum CodingKeys: String, CodingKey {
		case feeType = "feeType"
		case amount = "amount"
		case vat = "vat"
		case totalFee = "totalFee"
		case displayOnly = "displayOnly"
		case tierRateDTOList = "tierRateDTOList"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		feeType = try values.decodeIfPresent(String.self, forKey: .feeType)
		amount = try values.decodeIfPresent(Double.self, forKey: .amount)
		vat = try values.decodeIfPresent(Double.self, forKey: .vat)
		totalFee = try values.decodeIfPresent(Double.self, forKey: .totalFee)
		displayOnly = try values.decodeIfPresent(Bool.self, forKey: .displayOnly)
		tierRateDTOList = try values.decodeIfPresent([TierRateDTOList].self, forKey: .tierRateDTOList)
	}

}

struct TierRateDTOList: Codable {
    let amountFrom: Int?
    let amountTo: Int?
    let feeAmount: Int?
    let vatAmount: Int?
    let feePercentage: Int?
    let vatPercentage: Int?
    let feeInPercentage: Bool?

    enum CodingKeys: String, CodingKey {

        case amountFrom = "amountFrom"
        case amountTo = "amountTo"
        case feeAmount = "feeAmount"
        case vatAmount = "vatAmount"
        case feePercentage = "feePercentage"
        case vatPercentage = "vatPercentage"
        case feeInPercentage = "feeInPercentage"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        amountFrom = try values.decodeIfPresent(Int.self, forKey: .amountFrom)
        amountTo = try values.decodeIfPresent(Int.self, forKey: .amountTo)
        feeAmount = try values.decodeIfPresent(Int.self, forKey: .feeAmount)
        vatAmount = try values.decodeIfPresent(Int.self, forKey: .vatAmount)
        feePercentage = try values.decodeIfPresent(Int.self, forKey: .feePercentage)
        vatPercentage = try values.decodeIfPresent(Int.self, forKey: .vatPercentage)
        feeInPercentage = try values.decodeIfPresent(Bool.self, forKey: .feeInPercentage)
    }

}
