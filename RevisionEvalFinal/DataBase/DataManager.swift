//
//  DataManager.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 22/10/2023.
//

import Foundation
import CoreData

class DataManager {
    // pour avoir accès aux méthodes de n'importe où
    static var shared = DataManager()
    
    let context: NSManagedObjectContext
    
    init() {
        let container = NSPersistentContainer(name: "FavoriteDB")
        
        let dbFileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("db.sqlite")
        
        let storeDescription = NSPersistentStoreDescription(url: dbFileURL)
        storeDescription.type = NSSQLiteStoreType
        
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores {
            description, error in
            if let error = error {
                print("Error loading persistent store: ", error)
            }
        }
        context = container.viewContext
    }
    
    private func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving context", error)
        }
    }
    func addFavorite(id: Int32, date: String, name: String, rate: Double, imageUrl: String) {
        let favorite = Favorite(context: context)
        favorite.id = id
        favorite.releaseDate = date
        favorite.name = name
        favorite.rate = rate
        favorite.imageUrl = imageUrl
        
        saveContext()
    }
    func deleteFavorite(favorite: Favorite) {
        context.delete(favorite)
        
        saveContext()
    }
    func deleteFavoriteById(withID id: Int) {
            let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()

            // Utilisez un prédicat pour rechercher le film par son ID
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)

            do {
                if let movieToDelete = try context.fetch(fetchRequest).first {
                    context.delete(movieToDelete)
                    saveContext()
                }
            } catch {
                print("Error deleting movie: (error)")
            }
        }
    // voir si l'id existe déjà dans la db
    func idExists(id: Int) -> Bool {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        
        // Utilisez un prédicat pour rechercher l'ID
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty // Si des résultats sont retournés, l'ID existe déjà
        } catch {
            print("Error checking ID existence: \(error)")
            return false
        }
    }

}
