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
        
    
    @IBOutlet weak var showHideHistory: UIBarButtonItem!
    
    var disposeBag = DisposeBag()
    
    var queue:Variable<[Track]> = Variable([])
    var history:Variable<[Track]> = Variable([])
    var nextElement:Variable<Track>?
    var historyShowing:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.register(UINib(nibName: "SpotifySearchCell", bundle: nil ), forCellReuseIdentifier: "queueCell")
        
        self.tableView.dataSource = nil
        self.tableView.delegate = self
        let dataSource = RxTableViewSectionedAnimatedDataSource<TrackSection>()
        
        let sections: [TrackSection] = [TrackSection(header: "Up Next", tracks: [], updated: Date())]
        
        let dataSections:[Variable<[Track]>] = [queue,history]
        let state = SectionedQueueTableViewState(sections: sections,data:dataSections,current: dataSections[0],showHistory:true)
    
        let addCommand = queue.asObservable().map(TableViewEditingCommand.addTrack)
        //let historyCommand = history.asObservable().map(TableViewEditingCommand.addHistory)
        let deleteCommand = tableView.rx.itemDeleted.asObservable().map(TableViewEditingCommand.DeleteItem)
        let movedCommand = tableView.rx.itemMoved.map(TableViewEditingCommand.MoveItem)
        let toggleHistoryCommand = showHideHistory.rx.tap.asObservable().map {
            return TableViewEditingCommand.ToggleHistory
        }
        
        
        skinTableViewDataSource(dataSource: dataSource)
        
        Observable.of(addCommand, deleteCommand, movedCommand, toggleHistoryCommand)
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(historyShowing)
        
        let cell = (tableView.cellForRow(at: indexPath) as! SpotifySearchCell)
        if cell.type == .History {
            queue.value.append(cell.track!)
        } else {
            
        }
        cell.setSelected(false, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = (tableView.cellForRow(at: indexPath) as! SpotifySearchCell)
        if cell.type == .Queue {
            return nil
        }
        return indexPath
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
        cell.type = item.type
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
    case ToggleHistory
}

struct SectionedQueueTableViewState {
    fileprivate var sections: [TrackSection]
    fileprivate var dataSections: [Variable<[Track]>]
    fileprivate var currentData: Variable<[Track]>
    fileprivate var toggle:Bool
    
    init(sections:[TrackSection],data:[Variable<[Track]>],current:Variable<[Track]>,showHistory:Bool) {
        self.sections = sections
        self.dataSections = data
        self.currentData = current
        self.toggle = showHistory
    }
    
    func execute(command:TableViewEditingCommand) -> SectionedQueueTableViewState {
        switch command {
        case .AppendItem(let appendEvent):
            if !toggle {
                let list:[TrackItem] = dataSections[1].value.map{TrackItem(track: $0, type: .History,date: Date() )}
                let section = [TrackSection(header: "History", tracks: list, updated: Date())]
                return SectionedQueueTableViewState(sections: section, data: dataSections, current:dataSections[0],showHistory:toggle)
            }
            var sections = self.sections
            let items = appendEvent.list
                sections[appendEvent.section] = TrackSection(original: sections[appendEvent.section], items: items)

            return SectionedQueueTableViewState(sections: sections,data:dataSections, current:currentData,showHistory:toggle)
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            dataSections[indexPath.section].value.remove(at: indexPath.row)
            sections[indexPath.section] = TrackSection(original: sections[indexPath.section], items: items)
            return SectionedQueueTableViewState(sections: sections,data:dataSections, current:currentData,showHistory:toggle)
        case .MoveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: moveEvent.sourceIndex.row),
                                        at: moveEvent.destinationIndex.row)
                let destinationSection = TrackSection(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                
                dataSections[moveEvent.sourceIndex.section].value = destinationItems.map { $0.track }
                
                sections[moveEvent.sourceIndex.section] = destinationSection
                
                return SectionedQueueTableViewState(sections: sections,data:dataSections, current:currentData,showHistory:toggle)
            } else {
                let item = sourceItems.remove(at: moveEvent.sourceIndex.row)
                destinationItems.insert(item, at: moveEvent.destinationIndex.row)
                let sourceSection = TrackSection(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = TrackSection(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndex.section] = destinationSection
                
                dataSections[moveEvent.sourceIndex.section].value = sourceItems.map{$0.track}
                dataSections[moveEvent.destinationIndex.section].value = destinationItems.map{$0.track}
                return SectionedQueueTableViewState(sections: sections,data:dataSections, current:currentData,showHistory:toggle)
            }
        case .ToggleHistory:
            
            if toggle {
                let list:[TrackItem] = dataSections[1].value.map{TrackItem(track: $0, type: .History,date: Date() )}
                let section = [TrackSection(header: "History", tracks: list, updated: Date())]
                return SectionedQueueTableViewState(sections: section, data: dataSections, current:dataSections[0],showHistory:!toggle)
            }
            let list:[TrackItem] = dataSections[0].value.map{TrackItem(track: $0, type: .Queue, date: Date())}
            let section = [TrackSection(header: "Up Next", tracks: list, updated: Date())]
            return SectionedQueueTableViewState(sections: section, data: dataSections, current:dataSections[1],showHistory:!toggle)
        }
    }
}

extension TableViewEditingCommand {
    static func addTrack(queue:[Track]) -> TableViewEditingCommand {
        var trackItem:[TrackItem] = []
        trackItem = queue.map { TrackItem(track: $0, type: .Queue, date: Date()) }
        return TableViewEditingCommand.AppendItem(list: trackItem, section: 0)
        
    }
    
    static func addHistory(history:[Track]) -> TableViewEditingCommand {
        var trackItem:[TrackItem] = []
        trackItem = history.map { TrackItem(track: $0, type: .History, date: Date()) }
        return TableViewEditingCommand.AppendItem(list: trackItem, section: 1)
    }
}





