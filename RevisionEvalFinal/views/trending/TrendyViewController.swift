//
//  TrendyViewController.swift
//  RevisionEvalFinal
//
//  Created by Duc Luu on 20/10/2023.
//

import UIKit
import Alamofire
import AlamofireImage

class TrendyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    let apiKey = "55530312075972a425f5fa13e21b218f"
    let apiUrl = "https://api.themoviedb.org/3/movie/popular"
    private var movieList: [Result] = []
    @IBOutlet weak var sortSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure le layout de la collectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //layout.itemSize = CGSize(width: 110, height: 170)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 10, height: 160)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        // Lie le layout à la collectionView
        trendingCollectionView.collectionViewLayout = layout
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        trendingCollectionView.isPagingEnabled = false
        trendingCollectionView.register(UINib(nibName: "CustomTrendingCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "CustomTrendingCollectionViewCell")
        appelReseau()
        // gère le tri
        sortSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    // trie par rate
    @objc func switchValueChanged() {
            if sortSwitch.isOn {
                self.sortMovieList()
            } else {
                appelReseau()
            }
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
                        self.trendingCollectionView.reloadData() // On force le rafraîchissement de TableView car on a mis à jour
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
    // Trie le tableau
    func sortMovieList() {
        movieList.sort { $0.voteAverage > $1.voteAverage }
        trendingCollectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomTrendingCollectionViewCell", for: indexPath) as! CustomTrendingCollectionViewCell
        let movieData = movieList[indexPath.row]
        // Utilise AlamofireImage pour télécharger et afficher l'image depuis l'URL
        if let imageURL = URL(string: "https://image.tmdb.org/t/p/original" + (movieData.posterPath ?? "/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg")) {
            customCell.movieImage.af.setImage(withURL: imageURL)
            customCell.rateLabel?.text = "\(String(format: "%.1f", movieData.voteAverage))"
        }
        return customCell
    }
    
    // Cellule clickable
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let liveData = movieList[indexPath.row]
        let detailViewController = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController
        detailViewController?.passData = liveData
        navigationController?.pushViewController(detailViewController!, animated: true)
    }
}
