//
//  Favorite+CoreDataProperties.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 24/10/2023.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var rate: Double
    @NSManaged public var imageUrl: String?
    @NSManaged public var releaseDate: String?

}

extension Favorite : Identifiable {

}
