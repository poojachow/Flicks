//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Pooja Chowdhary on 3/31/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var networkErrorView: UIView!
    @IBAction func refreshNetworkError(_ sender: Any) {
        fetchNetworkData()
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func segmentedControlViewChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            selectedViewAsTableView()
        case 1:
            selectedViewAsCollectionView()
        default:
            selectedViewAsTableView()
        }
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkError: UILabel!
    var movies: [NSDictionary] = []
    var movieResults: [NSDictionary] = []
    var endpoint: String?
    var refreshControl: UIRefreshControl!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        fetchNetworkData()
        
    }
    
    func fetchNetworkData() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        collectionView.insertSubview(refreshControl, at: 0)
        
        refreshControlAction(refreshControl)

    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
    
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(self.endpoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let data = data {
                
                if let responseDictionary = try! JSONSerialization.jsonObject(
                    with: data, options:[]) as? NSDictionary {
                    //  print("responseDictionary: \(responseDictionary)")
                    self.movies = (responseDictionary["results"] as? [NSDictionary])!
                    self.movieResults = self.movies
                    DispatchQueue.main.async {
                        self.networkErrorView.isHidden = true
                        if self.segmentedControl.selectedSegmentIndex == 1 {
                            self.selectedViewAsCollectionView()
                        }
                        else {
                            self.selectedViewAsTableView()
                        }
                    }
                }
            }
            else {
                self.tableView.isHidden = true
                self.collectionView.isHidden = true
                self.networkErrorView.isHidden = false
                self.networkError.text = error?.localizedDescription
            }
            refreshControl.endRefreshing()
        }
        task.resume()
        
    }
    
    func selectedViewAsTableView() {
        self.tableView.isHidden = false
        self.collectionView.isHidden = true
        self.tableView.reloadData()
    }
    
    func selectedViewAsCollectionView() {
        tableView.isHidden = true
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        movieResults = movies
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        let searchedMovie = movies.filter{(item: NSDictionary)-> Bool in
            let temp = item["title"] as! String
            let stringMatch = temp.lowercased().range(of: searchText.lowercased())
            return stringMatch != nil ? true : false
        }
        
        if searchText.isEmpty {
            movieResults = movies
        }
        else {
            movieResults = searchedMovie
        }
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return movieResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGray
        cell.selectedBackgroundView = backgroundView
        let movie = movieResults[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.MovieLabel.text = title
        cell.MovieOverviewLabel.text = overview
        
        let baseurl = "https://image.tmdb.org/t/p/w500/"
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = URL(string: baseurl + posterPath)
            let imageRequest = URLRequest(url: imageURL!)
            cell.MovieImage.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    cell.MovieImage.alpha = 0.0
                    cell.MovieImage.image = image
                    UIView.animate(withDuration: 0.3, animations: { ()->Void in
                        cell.MovieImage.alpha = 1.0
                    })
                }
                else {
                    cell.MovieImage.image = image
                }
            },
            failure: {(imageRequest, imageResponse, error) -> Void in
            print(error)
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! MovieCollectionViewCell
        
        let movie = movieResults[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.MovieLabel.text = title
        cell.MovieOverviewLabel.text = overview
        
        let baseurl = "https://image.tmdb.org/t/p/w500/"
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = URL(string: baseurl + posterPath)
          //  cell.MovieImage.setImageWith(imageURL!)
            let imageRequest = URLRequest(url: imageURL!)
            cell.MovieImage.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    cell.MovieImage.alpha = 0.0
                    cell.MovieImage.image = image
                    UIView.animate(withDuration: 0.3, animations: { ()->Void in
                        cell.MovieImage.alpha = 1.0
                    })
                }
                else {
                    cell.MovieImage.image = image
                }
            },
            failure: {(imageRequest, imageResponse, error) -> Void in
                print(error)
            })
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var movie: NSDictionary?
        if segue.identifier == "collectionViewSegue" {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)
            movie = movieResults[(indexPath?.row)!]
        }
        else {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            movie = movieResults[(indexPath?.row)!]
        }
        
        let movieDetailVC = segue.destination as! MovieDetailViewController
        movieDetailVC.movie = movie
        
    }
 

}
