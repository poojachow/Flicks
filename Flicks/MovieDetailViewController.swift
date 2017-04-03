//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Pooja Chowdhary on 4/1/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var ReleaseDateLabel: UILabel!
    @IBOutlet weak var PosterImageView: UIImageView!
    @IBOutlet weak var MovieTitleLabel: UILabel!
    @IBOutlet weak var DurationLabel: UILabel!
    @IBOutlet weak var MovieOverviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movieDetailView: UIView!
    var movieDetail: NSDictionary!
    var movie : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height + movieDetailView.frame.height
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        movieDetailView.frame.origin.y = super.view.frame.height
    
        // Do any additional setup after loading the view.
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let releaseDate = movie["release_date"] as! String
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let movieId = movie["id"] as! Int
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)&language=en-US")
        
        MovieTitleLabel.text = title
        MovieOverviewLabel.text = overview
        MovieOverviewLabel.sizeToFit()
        ReleaseDateLabel.text = releaseDate
        
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(
                    with: data, options:[]) as? NSDictionary {
                    self.movieDetail = responseDictionary
                    DispatchQueue.main.async {
                        self.DurationLabel.text = "\((self.movieDetail["runtime"])!) min"
                    }
                }
            }
            else {
                print(error ?? "Unknown error")
            }
        }
        task.resume()
        let baseurlLowResolution = "https://image.tmdb.org/t/p/w45/"
        let baseurlHighResolution = "https://image.tmdb.org/t/p/original/"
        if let posterPath = movie["poster_path"] as? String {
            let smallImageRequest = URLRequest(url: URL(string: baseurlLowResolution+posterPath)!)
            let largeImageRequest = URLRequest(url: URL(string: baseurlHighResolution+posterPath)!)
            PosterImageView.setImageWith(smallImageRequest, placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) in
                self.PosterImageView.alpha = 0.0
                self.PosterImageView.image = smallImage
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    self.PosterImageView.alpha = 1.0
                    
                }, completion: { (sucess) -> Void in
                    self.PosterImageView.setImageWith(largeImageRequest, placeholderImage: smallImage, success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                        self.PosterImageView.image = largeImage
                    }, failure: { (request, response, error) in
                        print(error)
                    })
                })
                
            }, failure: { (request, response, error) in
                print(error)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
