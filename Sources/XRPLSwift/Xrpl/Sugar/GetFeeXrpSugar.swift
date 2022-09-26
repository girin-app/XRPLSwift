//
//  GetFeeXrpSugar.swift
//  
//
//  Created by Denis Angell on 8/21/22.
//

// https://github.com/XRPLF/xrpl.js/blob/main/packages/xrpl/src/sugar/getFeeXrp.ts

import Foundation

// swiftlint:disable:next identifier_name
let NUM_DECIMAL_PLACES: Int = 6
// swiftlint:disable:next identifier_name
let BASE_10: Int = 10

/**
 * Calculates the current transaction fee for the ledger.
 * Note: This is a public API that can be called directly.
 *
 * @param client - The Client used to connect to the ledger.
 * @param cushion - The fee cushion to use.
 * @returns The transaction fee.
 */
public func getFeeXrp(
    client: XrplClient,
    cushion: Double? = nil
) async throws -> String {
    let feeCushion = cushion ?? client.feeCushion

    let request = try ServerInfoRequest(["command": "server_info"] as [String: AnyObject])
    let response = try await client.request(request).wait() as? BaseResponse<ServerInfoResponse>
    guard let response = response else { throw XrplError("Invalid Response") }
    guard let result = response.result else { throw XrplError("Invalid Result") }

    let serverInfo = result.info
    guard let baseFee = serverInfo.validatedLedger?.baseFeeXrp else {
        throw XrplError("Xrp: Could not get base_fee_xrp from server_info")
    }

    let baseFeeXrp = Double(baseFee)
    if serverInfo.loadFactor == nil {
        // https://github.com/ripple/rippled/issues/3812#issuecomment-816871100
        serverInfo.loadFactor = 1
    }
    var fee = baseFeeXrp * Double(serverInfo.loadFactor!) * feeCushion
    // Cap fee to `client.maxFeeXRP`
    fee = min(fee, Double(client.maxFeeXRP)!)
    // Round fee to 6 decimal places
    return fee.description
}
