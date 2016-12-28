//
//  ResultsTableViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/8/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {

    var resized:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.indicatorStyle = .white

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resize()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func resize() {
        if AppState.sharedInstance.playerShowing {
            let insets = UIEdgeInsetsMake(0, 0, 64, 0)
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
        }
    }
    
    
    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textAlignment = .center
            header.textLabel?.textColor = .white
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            header.contentView.backgroundColor = UIColor.darkGray
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = tableView.headerView(forSection: indexPath.section)?.textLabel?.text ?? ""
        switch section {
        case "Artists","Albums":
            return 60
        default:
            return 44
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    

    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
