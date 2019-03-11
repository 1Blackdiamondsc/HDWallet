//
//  BitcoinUtxoProvider.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 2/19/19.
//  Copyright © 2019 Essentia. All rights reserved.
//

import Foundation
import EssentiaNetworkCore

final public class BitcoinComUtxoProvider: UtxoProviderInterface {
    let networkManager: NetworkManager
    public init() {
        self.networkManager = NetworkManager("https://rest.bitcoin.com/v1/")
    }
    
    // GET API: reload utxos
    public func reload(address: Address, completion: @escaping (([UnspentTransaction]) -> Void)) {
        networkManager.makeAsyncRequest(BitcoinComApiEndPoint.utxo(address: address)) { (result: NetworkResult
            <[[BitcoinComUtxoModel]]>) in
            switch result {
            case .success(let utxos):
                completion(utxos.joined().asUtxos())
            case .failure(let error):
                Logger.shared.logEvent(.message(.error, error.localizedDescription))
            }
        }
    }
}

private extension Sequence where Element == BitcoinComUtxoModel {
    func asUtxos() -> [UnspentTransaction] {
        return compactMap { $0.asUtxo() }
    }
}

// MARK: - GET Unspent Transaction Outputs
private struct BitcoinComUtxoModel: Codable {
    let txid: String
    let vout: UInt32
    let scriptPubKey: String
    let amount: Decimal
    let satoshis: UInt64
    let height: Int?
    let confirmations: Int
    let legacyAddress: String
    let cashAddress: String
    
    func asUtxo() -> UnspentTransaction {
        let lockingScript: Data = Data(hex: scriptPubKey)
        let txidData: Data = Data(hex: String(txid))
        let txHash: Data = Data(txidData.reversed())
        let output = TransactionOutput(value: satoshis, lockingScript: lockingScript)
        let outpoint = TransactionOutPoint(hash: txHash, index: vout)
        return UnspentTransaction(output: output, outpoint: outpoint)
    }
}
