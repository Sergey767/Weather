//
//  UITableView+Ext.swift
//  Vkontakte
//
//  Created by Сергей Горячев on 03.08.2020.
//  Copyright © 2020 appleS. All rights reserved.
//

import UIKit

extension UITableView {
    func update(deletions: [Int], insertions: [Int], modifications: [Int]) {
        beginUpdates()
        deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
        insertRows(at: insertions.map({ IndexPath(row: $0, section: 0 )}), with: .automatic)
        reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
        endUpdates()
    }
}
