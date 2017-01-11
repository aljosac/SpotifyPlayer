//
//  ResultsTableViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 12/8/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.indicatorStyle = .white
        self.tableView.separatorColor = tableGray
        resize()
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
        
        if AppState.shared.playerShowing {
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
            header.contentView.backgroundColor = dark
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) as? ResultTableViewCell {
            switch cell.cellType! {
            case .TrackCell:
                if cell.accessoryType == .checkmark {
                    return nil
                }
                fallthrough
            default:
                return indexPath
            }
        }
        return indexPath
    }
    
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let cell = tableView.cellForRow(at: indexPath) as? ResultTableViewCell {
            switch cell.cellType! {
            case .TrackCell:
                if cell.accessoryType == .checkmark {
                    return false
                }
                fallthrough
            default:
                return true
            }
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = tableView.headerView(forSection: indexPath.section)?.textLabel?.text ?? ""
        switch section {
        case "Artists","Albums":
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                return 44
            }
            return 60
            
        default:
            return 44
        }
    }
    

}
