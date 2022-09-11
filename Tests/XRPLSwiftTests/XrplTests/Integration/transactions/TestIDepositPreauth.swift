//
//  TestIDepositPreauth.swift
//  
//
//  Created by Denis Angell on 8/26/22.
//

// https://github.com/XRPLF/xrpl.js/blob/main/packages/xrpl/test/integration/transactions/depositPreauth.ts

import XCTest
@testable import XRPLSwift

final class TestIDepositPreauth: RippledITestCase {

    let TIMEOUT: Double = 20

    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testJson() async {
        // create the expectation
        let exp = expectation(description: "base")

        let wallet2: Wallet = await generateFundedWallet(client: self.client)
        let json = [
            "TransactionType": "DepositPreauth",
            "Account": self.wallet.classicAddress,
            "Authorize": wallet2.classicAddress
        ] as [String: AnyObject]
        let tx: Transaction = try! Transaction(json)!
        await testTransaction(
            client: self.client,
            transaction: tx,
            wallet: self.wallet
        )
        exp.fulfill()
        await waitForExpectations(timeout: TIMEOUT)
    }
}
