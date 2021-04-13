//
//  FlexibleElementCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public protocol FlexibleElementCoder {
    func decode(context: FlexibleContext<FlexibleReadingWorkzone>, extra: Any?) throws -> FlexibleAnyElement?
    func encode(context: FlexibleContext<FlexibleWritingWorkzone>, anyElement: FlexibleAnyElement, depth: Int) -> Bool
}
