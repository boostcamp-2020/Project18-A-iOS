//
//  Travel+CoreDataClass.swift
//  BoostPocket
//
//  Created by 이승진 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Travel)
public class Travel: NSManagedObject, DataModelProtocol {
    static let entityName = "Travel"
}
