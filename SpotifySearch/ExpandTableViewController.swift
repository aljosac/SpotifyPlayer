//
//  ExpandTableViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/30/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import Alamofire

class ExpandTableViewController: UITableViewController {

    var data:[SimpleAlbum] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "AlbumTableViewCell", bundle: nil), forCellReuseIdentifier: "albumCell")
        self.tableView.backgroundColor = tableGray
        self.tableView.separatorColor = tableGray
        
        self.title = "Albums"
        self.tableView.estimatedRowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resize()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! AlbumTableViewCell
        let album = data[indexPath.row]
        if album.images.count > 0 {
            Alamofire.request(album.images[0].url).responseData { response in
                if let data = response.data {
                    let image:UIImage = UIImage(data: data)!
                    cell.albumCover.image = image
                }
            }
        }
        cell.albumName.text = album.name
        cell.artistName.text = album.artists.map{$0.name}.joined(separator: ",")
        cell.id = album.id
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumCell = tableView.cellForRow(at: indexPath) as! AlbumTableViewCell
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let albumPage = storyboard.instantiateViewController(withIdentifier:"albumPage") as! AlbumPageViewController
        
        albumPage.id = albumCell.id
        albumPage.albumImage = albumCell.albumCover.image
        self.navigationController?.pushViewController(albumPage, animated: true)
    }
    
    func resize() {
        if AppState.shared.playerShowing {
            let insets = UIEdgeInsetsMake(0, 0, 64, 0)
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
        }
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
