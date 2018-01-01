//
//  UInt8+Extension.swift
//  WalletKit
//
//  Created by yuzushioh on 2018/01/01.
//  Copyright © 2018 yuzushioh. All rights reserved.
//

import Foundation

extension UInt8 {
    var bits: [String] {
        let totalBitsCount = MemoryLayout<UInt8>.size * 8
        var bitsArray = [String](repeating: "0", count: totalBitsCount)
        
        for count in 0 ..< totalBitsCount {
            let bitValue: UInt8 = 1 << UInt8(totalBitsCount - 1 - count)
            let check = self & bitValue
            if check != 0 {
                bitsArray[count] = "1"
            }
        }
        return bitsArray
    }
}
