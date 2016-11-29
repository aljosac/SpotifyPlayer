//
//  QueueTableViewController.swift
//  SpotifySearch
//
//  Created by Aljosa Cucak on 11/15/16.
//  Copyright © 2016 cse-cucak003. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import RxDataSources


class QueueTableViewController: UITableViewController {

    @IBAction func toggleEdit(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }
    
    var disposeBag = DisposeBag()
    
    var queue:Variable<[Track]> = Variable([])
    var history:Variable<[Track]> = Variable([])
    var nextElement:Variable<Track>?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.register(UINib(nibName: "SpotifySearchCell", bundle: nil ), forCellReuseIdentifier: "queueCell")
        
        self.tableView.dataSource = nil
        let dataSource = RxTableViewSectionedAnimatedDataSource<TrackSection>()
        
        let sections: [TrackSection] = [TrackSection(header: "Up Next", tracks: [], updated: Date())]
        
        let state = SectionedQueueTableViewState(sections: sections)
    
        let addCommand = queue.asObservable().map(TableViewEditingCommand.addTrack)
        let deleteCommand = tableView.rx.itemDeleted.asObservable().map(TableViewEditingCommand.DeleteItem)
        let movedCommand = tableView.rx.itemMoved.map(TableViewEditingCommand.MoveItem)
    
        
        skinTableViewDataSource(dataSource: dataSource)
        
        Observable.of(addCommand, deleteCommand, movedCommand)
            .merge()
            .scan(state) { (state: SectionedQueueTableViewState, command: TableViewEditingCommand) -> SectionedQueueTableViewState in
                return state.execute(command: command)
            }
            .startWith(state)
            .map {
                $0.sections
            }
            .shareReplay(1)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //tableView.setEditing(true, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

func skinTableViewDataSource(dataSource: RxTableViewSectionedAnimatedDataSource<TrackSection>){
    dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                               reloadAnimation: .fade,
                                                               deleteAnimation: .left)
    
    dataSource.configureCell = { (dataSource, table, idxPath, item) in
        let cell = table.dequeueReusableCell(withIdentifier: "queueCell", for: idxPath) as! SpotifySearchCell
        cell.mainLabel?.text = item.track.name
        cell.sublabel.text = item.track.artists[0].name
        cell.track = item.track
        return cell
    }
    
    dataSource.titleForHeaderInSection = { (ds, section) -> String? in
        return ds[section].header
    }
    
    dataSource.canEditRowAtIndexPath = { _ in
        return true
    }
    dataSource.canMoveRowAtIndexPath = { _ in
        return true
    }
}

enum TableViewEditingCommand {
    case AppendItem(list: [TrackItem], section: Int)
    case MoveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case DeleteItem(IndexPath)
}

struct SectionedQueueTableViewState {
    fileprivate var sections: [TrackSection]
    
    init(sections:[TrackSection]) {
        self.sections = sections
    }
    
    func execute(command:TableViewEditingCommand) -> SectionedQueueTableViewState {
        switch command {
        case .AppendItem(let appendEvent):
            var sections = self.sections
            let items = appendEvent.list
            sections[appendEvent.section] = TrackSection(original: sections[appendEvent.section], items: items)
            return SectionedQueueTableViewState(sections: sections)
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = TrackSection(original: sections[indexPath.section], items: items)
            return SectionedQueueTableViewState(sections: sections)
        case .MoveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: moveEvent.sourceIndex.row),
                                        at: moveEvent.destinationIndex.row)
                let destinationSection = TrackSection(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                
                sections[moveEvent.sourceIndex.section] = destinationSection
                
                return SectionedQueueTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: moveEvent.sourceIndex.row)
                destinationItems.insert(item, at: moveEvent.destinationIndex.row)
                let sourceSection = TrackSection(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = TrackSection(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndex.section] = destinationSection
                
                return SectionedQueueTableViewState(sections: sections)
            }
        }
    }
}

extension TableViewEditingCommand {
    static func addTrack(queue:[Track]) -> TableViewEditingCommand {
        var trackItem:[TrackItem] = []
        trackItem = queue.map { TrackItem(track: $0,date: Date()) }
        return TableViewEditingCommand.AppendItem(list: trackItem, section: 0)
        
    }
}





