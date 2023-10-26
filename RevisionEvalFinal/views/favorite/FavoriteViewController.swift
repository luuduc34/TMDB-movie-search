//
//  FavoriteViewController.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 24/10/2023.
//

import UIKit
import CoreData
import Alamofire

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var favoriteTableView: UITableView!
    @IBOutlet weak var tmdbLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    let context = DataManager.shared.context
    var resultsController: NSFetchedResultsController<Favorite>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //favoriteTableView.reloadData()
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        fetchData()
        favoriteTableView.reloadData()
        resultsController.delegate = self
        // lier le nib avec la customCell
        favoriteTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "CustomTableViewCell")
        
        // Créez une image de dégradé de couleur de gauche à droite.
        let gradientImage = gradientImageWithBounds(bounds: tmdbLabel.bounds, colors: [UIColor.green, UIColor.blue])
        
        // Appliquez l'image en tant qu'arrière-plan du label.
        tmdbLabel.textColor = UIColor(patternImage: gradientImage)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Mettez ici le code pour rafraîchir votre tableau
        fetchData()
        favoriteTableView.reloadData() // Par exemple, pour un UITableView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = resultsController?.object(at: indexPath)
        let customCell = favoriteTableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        
        customCell.titleLabel.text = movie?.name
        
        // Créez un DateFormatter
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd"
        // Convertir la chaîne d'entrée en objet Date
        
        if let date = inputDateFormatter.date(from: movie!.releaseDate!) {
            // Créez un nouveau DateFormatter pour le format de sortie
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "MMMM, dd yyyy"// "MMMM, dd yyyy" -> "April, 22 2020"
            
            customCell.dateLabel.text = outputDateFormatter.string(from: date)
        } else {
            print("Erreur de conversion de la date")
        }
        
        customCell.rateLabel.text = "\(String(format: "%.1f", movie!.rate))"
        
        // Utilise AlamofireImage pour télécharger et afficher l'image depuis l'URL
        if let imageURL = URL(string: "https://image.tmdb.org/t/p/original" + (movie?.imageUrl ?? "/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg")) {
            customCell.movieImage.af.setImage(withURL: imageURL)
        }
        
        return customCell
    }
    // ajout de la fonction "slide, effacer"
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = resultsController.object(at: indexPath)
            DataManager.shared.deleteFavorite(favorite: movie)
            fetchData()
            favoriteTableView.reloadData()
        }
    }
    func fetchData() {
        
        // fetch des données
        let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
        fetchRequest.sortDescriptors = [
            // query: filtre d'abord par nom de type
            //NSSortDescriptor(key: "sectionDepense.nom", ascending: true),
            // query: filtre par nom
            NSSortDescriptor(key: "name", ascending: true)
        ]
        resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil
        )
        do {
            try resultsController.performFetch()
        } catch {
            print("Could not fetch receipes : ", error)
        }
    }
    // Création du dégradé
    func gradientImageWithBounds(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: -1.0, y: 0.5) // x commence à -1 du texte (horizontal), y c'est le milieu du texte (vertical)
        gradientLayer.endPoint = CGPoint(x: 2.0, y: 0.5) // x termine à +2 du texte (horizontal), y c'est le milieu du texte (vertical)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage!
    }
    
    // MARK: - Update tableview
    // gère l'écoute et la mise à jour auto de la tableview (catégories)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            favoriteTableView.insertSections([sectionIndex], with: .automatic)
        case .delete:
            favoriteTableView.deleteSections([sectionIndex], with: .automatic)
        default:
            break
        }
    }
    // gère l'écoute et la mise à jour auto de la tableview
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.endUpdates()
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            favoriteTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            favoriteTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            favoriteTableView.deleteRows(at: [indexPath!], with: .automatic)
            favoriteTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            favoriteTableView.reloadRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
}
