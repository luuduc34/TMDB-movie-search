//
//  DetailViewController.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 20/10/2023.
//

import UIKit
import Alamofire
import YouTubePlayerKit
import CoreData
//import AlamofireImage

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var rateBackCircle: UIView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var synopsisTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var favoriteIco: UIButton!
    private var isFavorite: Bool?

    var passData: Result!
    
    let apiKey = "55530312075972a425f5fa13e21b218f"
    var apiUrl = ""
    var apiVideoUrl = ""

    private var movieList: [Result] = []
    private var movieListVideo: [ResultVideo] = [] // pour youtube
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        
        movieTitle.text = passData.title
        // Utilise AlamofireImage pour télécharger et afficher l'image depuis l'URL
        if let imageURL = URL(string: "https://image.tmdb.org/t/p/original" + (passData.backdropPath ?? "/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg")) {
            backImage.af.setImage(withURL: imageURL)
        }
        // Utilise AlamofireImage pour télécharger et afficher l'image depuis l'URL
        if let imageURL = URL(string: "https://image.tmdb.org/t/p/original" + (passData.posterPath ?? "/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg")) {
            movieImage.af.setImage(withURL: imageURL)
        }
        movieImage.layer.cornerRadius = 15
        movieImage.layer.borderWidth = 3
        movieImage.layer.borderColor = UIColor.white.cgColor
        
        rateLabel.text = "\(String(format: "%.1f", passData.voteAverage))"
        
        rateBackCircle.layer.cornerRadius = rateBackCircle.frame.width / 2
        rateBackCircle.layer.borderWidth = 1
        rateBackCircle.layer.borderColor = UIColor.red.cgColor
        //rateBackCircle.alpha = 0.9
        
        synopsisTextView.text = passData.overview
        
        apiUrl = "https://api.themoviedb.org/3/movie/\(passData.id)/similar"
        appelReseau()
        
        //Top layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 230)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        //layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 30, height: 200)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = false
        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "CustomCollectionViewCell")
        // gère l'affichage des favoris
        if DataManager.shared.idExists(id: passData.id) {
            favoriteIco.setImage(UIImage(systemName: "star.fill"), for: .normal)
            isFavorite = true
        } else {
            favoriteIco.setImage(UIImage(systemName: "star"), for: .normal)
            isFavorite = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DataManager.shared.idExists(id: passData.id) {
            favoriteIco.setImage(UIImage(systemName: "star.fill"), for: .normal)
            isFavorite = true
        } else {
            favoriteIco.setImage(UIImage(systemName: "star"), for: .normal)
            isFavorite = false
        }
    }
    @IBAction func favoriteBtn() {
        isFavorite?.toggle()
        favoriteIco.setImage(isFavorite! ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"), for: .normal)
        if isFavorite! {
            //userDefaults.set("true", forKey: String(passData.id))
            DataManager.shared.addFavorite(id: Int32(passData.id), date: passData.releaseDate, name: passData.title, rate: passData.voteAverage, imageUrl: passData.posterPath ?? "/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg")
        } else {
            //userDefaults.set("false", forKey: String(passData.id))
            DataManager.shared.deleteFavoriteById(withID: passData.id)
        }
    }
    @IBAction func videoBtn() {
        appelReseauVideo()
    }
    
    @objc func appelReseau() {
        // appel réseau avec query parameters
        let parameters: [String: Any] = ["page": 1, "api_key": apiKey]
        
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
                        self.collectionView.reloadData() // On force le rafraîchissement de TableView car on a mis à jour
                    }
                    // On gère les erreurs
                } catch let error {
                    print("ERROR DETECTED: \(error)")
                }
            case .failure(let error):
                print("ERROR DETECTED: \(error)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        let movieData = movieList[indexPath.row]
        // Utilise AlamofireImage pour télécharger et afficher l'image depuis l'URL
        if let imageURL = URL(string: "https://image.tmdb.org/t/p/original" + (movieData.posterPath ?? "/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg")) {
            customCell.movieImage.af.setImage(withURL: imageURL)
        }
        customCell.movieLabel.text = movieData.title
        return customCell
    }
    // Cellule clickable
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let liveData = movieList[indexPath.row]
        let detailViewController = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController
        detailViewController?.passData = liveData
        navigationController?.pushViewController(detailViewController!, animated: true)
    }
    
    // pour youtube
    @objc func appelReseauVideo() {
        // appel réseau avec query parameters
        let parameters: [String: Any] = ["page": 1, "api_key": apiKey]
        let apiVideoUrl = "https://api.themoviedb.org/3/movie/\(passData.id)/videos" // pour youtube
        AF.request(apiVideoUrl, method: .get, parameters: parameters).response { dataResponse in
            switch dataResponse.result {
            case .success(let data):
                //Data est une optional donc on s'assure qu'elle n'est pas nulle sinon on sort
                guard let data = data else { return }
                let decoder = JSONDecoder()
                do {
                    let videoResponse = try decoder.decode(VideoResponse.self, from: data)
                    //On revient dans main car on modifie l'UI
                    DispatchQueue.main.async {
                        self.movieListVideo = videoResponse.results // Stocker les données obtenues
                        
                        let source: String = self.movieListVideo[0].key
                        let youTubePlayerViewController = YouTubePlayerViewController(
                            source: .video(id: source),
                            configuration: .init(
                                autoPlay: true
                            )
                        )
                        // Present YouTubePlayerViewController
                        self.navigationController?.pushViewController(youTubePlayerViewController, animated: true)
                    }
                    // On gère les erreurs
                } catch let error {
                    print("ERROR DETECTED: \(error)")
                }
            case .failure(let error):
                print("ERROR DETECTED: \(error)")
            }
        }
    }
}
