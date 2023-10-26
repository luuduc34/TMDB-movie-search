//
//  SearchViewController.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 20/10/2023.
//

import UIKit
import Alamofire
import CoreData
//import AlamofireImage

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var nothing: UIStackView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSwitch: UISwitch!
    @IBOutlet weak var sortStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchIndicatorLabel: UILabel!
    
    let apiKey = "55530312075972a425f5fa13e21b218f"
    let apiUrl = "https://api.themoviedb.org/3/search/movie"
    private var searchTimer: Timer?
    private var movieList: [Result] = []
    
    var toggle: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        // Lier datasource & delegate à tableView et référence la custom cell
        tableView.dataSource = self
        tableView.delegate = self
        searchField.delegate = self
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "CustomTableViewCell")
        // masque la searchField et affiche le searchLabel
        searchField.isHidden = toggle
        searchLabel.isHidden = !toggle
        sortStackView.isHidden = toggle
        
        // Créez une image de dégradé de couleur de gauche à droite.
        let gradientImage = gradientImageWithBounds(bounds: searchLabel.bounds, colors: [UIColor.green, UIColor.blue])
        
        // Appliquez l'image en tant qu'arrière-plan du label.
        searchLabel.textColor = UIColor(patternImage: gradientImage)
        //searchLabel.textColor = UIColor.white // Couleur du texte
        
        searchField.layer.cornerRadius = 13
        searchField.clipsToBounds = true

        activityIndicator.hidesWhenStopped = true // Pour le masquer lorsque vous l'arrêtez
        searchIndicatorLabel.isHidden = true
        //DataManager.shared.addFavorite(id: 844, name: "Sonic", rate: 8.0, imageUrl: "Hello")
        // masquer le clavier sur tap hors du clavier
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    // ecoute le clavier pour le masquer
    @objc func keyboardWasShown(_ notification: Notification) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func keyboardWillBeHidden(_ notification: Notification) {
        view.gestureRecognizers?.forEach { view.removeGestureRecognizer($0) }
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    // retirer les observeurs quand la vue est déchargée
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // trie par rate
    @IBAction func switchValueChanged() {
            if sortSwitch.isOn {
                self.sortMovieList()
            } else {
                appelReseau()
            }
        }
    
    @IBAction func search() {
        toggle.toggle()
        searchField.isHidden = toggle
        searchLabel.isHidden = !toggle
        sortStackView.isHidden = toggle
        searchBtn.setImage(toggle ? UIImage(systemName: "magnifyingglass") : UIImage(systemName: "xmark"), for: .normal)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Timer de 2 sec pour éviter trop d'appel api
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(appelReseau), userInfo: nil, repeats: false)
        // Cacher la tableView si le champ de recherche est vide
        if (textField.text?.isEmpty ?? true) {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
        // Démarrer l'indicateur d'activité
            activityIndicator.startAnimating()
        searchIndicatorLabel.isHidden = false
        return true
    }
    
    @objc func appelReseau() {
        // appel réseau avec query parameters
        let parameters: [String: Any] = ["query": searchField.text!, "page": 1, "api_key": apiKey]
        
        AF.request(apiUrl, method: .get, parameters: parameters).response { dataResponse in
            switch dataResponse.result {
            case .success(let data):
                //Data est une optional donc on s'assure qu'elle n'est pas nulle sinon on sort
                guard let data = data else { return }
                let decoder = JSONDecoder()
                do {
                    let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                    //On revient dans main car on modifie l'UI
                    DispatchQueue.main.async {
                        self.movieList = movieResponse.results // Stocker les données obtenues
                        
                        self.tableView.reloadData() // On force le rafraîchissement de TableView car on a mis à jour
                    }
                    // On gère les erreurs
                } catch let error {
                    print("ERROR DETECTED: \(error)")
                }
            case .failure(let error):
                print("ERROR DETECTED: \(error)")
            }
        }
        // Arrêtez l'indicateur d'activité lorsque la recherche est terminée
            activityIndicator.stopAnimating()
        searchIndicatorLabel.isHidden = true
    }
    // Trie le tableau
    func sortMovieList() {
        movieList.sort { $0.voteAverage > $1.voteAverage }
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        let movieData = movieList[indexPath.row]
        
        customCell.titleLabel.text = movieData.title
        
        // Créez un DateFormatter
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd"
        // Convertir la chaîne d'entrée en objet Date
        if let date = inputDateFormatter.date(from: movieData.releaseDate) {
            // Créez un nouveau DateFormatter pour le format de sortie
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "MMMM, dd yyyy"// "MMMM, dd yyyy" -> "April, 22 2020"
            
            customCell.dateLabel.text = outputDateFormatter.string(from: date)
        } else {
            print("Erreur de conversion de la date")
        }
        
        customCell.rateLabel.text = "\(String(format: "%.1f", movieData.voteAverage))"
        
        // Utilise AlamofireImage pour télécharger et afficher l'image depuis l'URL
        if let imageURL = URL(string: "https://image.tmdb.org/t/p/original" + (movieData.posterPath ?? "/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg")) {
            customCell.movieImage.af.setImage(withURL: imageURL)
        }
        return customCell
    }
    
    // Cellule clickable
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let liveData = movieList[indexPath.row]
        let detailViewController = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController
        detailViewController?.passData = liveData
        navigationController?.pushViewController(detailViewController!, animated: true)
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
}
