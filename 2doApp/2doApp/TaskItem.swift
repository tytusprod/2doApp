//
//  TaskItem.swift
//  2doApp
//
//  Created by Michal T on 29/10/2021.
//

import Foundation

class TaskItem: NSObject, Codable {
    var name = ""
    var checked = false
    var date: Date? = Date.now
    var list = ""
}
