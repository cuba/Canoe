//
//  SimpleRow.swift
//  Example
//
//  Created by Jacob Sikorski on 2021-10-27.
//

import Foundation
import UIKit
import Canoe

struct SimpleRow: TableViewHelperIdentifiable {
    enum RowType: String, CaseIterable {
        case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
    }

    let id: UUID
    let type: RowType
}
