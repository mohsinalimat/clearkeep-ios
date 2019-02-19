//
//  CKRoomSettingsViewController.swift
//  Riot
//
//  Created by Sinbad Flyce on 1/7/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import Foundation

protocol CKRoomSettingsViewControllerDelegate: class {
    func roomSettingsDidLeave()
}

@objc class CKRoomSettingsViewController: MXKRoomSettingsViewController {
    
    // MARK: - PROPERTY
    
    /**
     TableView Section Type
     */
    enum TableViewSectionType {
        case infos
        case settings
        case actions
        
        static func count() -> Int {
            return 3
        }
    }    
    
    /**
     delegate
     */
    weak var delegate: CKRoomSettingsViewControllerDelegate?
    
    /**
     Cells heigh
     */
    private let kInfoCellHeigh: CGFloat     = 80.0
    private let kDefaultCellHeigh: CGFloat  = 60.0
    
    /**
     tblSections
     */
    private var tblSections: [TableViewSectionType] = [.infos, .settings, .actions]
    
    /**
     extraEventsListener
     */
    private var extraEventsListener: Any!
    
    /**
     mxRoom
     */
    private var mxRoom: MXRoom! {
        return self.value(forKey: "mxRoom") as? MXRoom
    }
    
    /**
     mxRoomState
     */
    private var mxRoomState: MXRoomState! {
        return self.value(forKey: "mxRoomState") as? MXRoomState
    }    
    
    // MARK: - CLASS
    
    public override class func nib() -> UINib? {
        return UINib.init(
            nibName: String(describing: CKRoomSettingsViewController.self),
            bundle: Bundle(for: self))
    }
    
    // MARK: - PRIVATE
    
    private func setupTableView()  {
        
        self.tableView.register(CKRoomSettingsRoomNameCell.nib, forCellReuseIdentifier: CKRoomSettingsRoomNameCell.identifier)
        self.tableView.register(CKRoomSettingsTopicCell.nib, forCellReuseIdentifier: CKRoomSettingsTopicCell.identifier)
        self.tableView.register(CKRoomSettingsMembersCell.nib, forCellReuseIdentifier: CKRoomSettingsMembersCell.identifier)
        self.tableView.register(CKRoomSettingsFilesCell.nib, forCellReuseIdentifier: CKRoomSettingsFilesCell.identifier)
        self.tableView.register(CKRoomSettingsMoreSettingsCell.nib, forCellReuseIdentifier: CKRoomSettingsMoreSettingsCell.identifier)
        self.tableView.register(CKRoomSettingsAddPeopleCell.nib, forCellReuseIdentifier: CKRoomSettingsAddPeopleCell.identifier)
        self.tableView.register(CKRoomSettingsLeaveCell.nib, forCellReuseIdentifier: CKRoomSettingsLeaveCell.identifier)

        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = CKColor.Background.tableView
        self.view.backgroundColor = CKColor.Background.tableView
        self.navigationItem.title = String.ck_LocalizedString(key: "Info")
        self.reloadTableView()
    }
    
    private func reloadTableView() {
        tblSections = [.infos, .settings, .actions]
        tableView.reloadData()
    }
    
    private func reflectDataUI() {
        self.tableView.reloadData()
    }
    
    private func cellForRoomName(_ indexPath: IndexPath) -> CKRoomSettingsRoomNameCell! {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsRoomNameCell.identifier ,
            for: indexPath) as! CKRoomSettingsRoomNameCell
        
        cell.roomnameLabel.text = self.mxRoom?.summary?.displayname
        return cell
    }
    
    private func cellForRoomTopic(_ indexPath: IndexPath) -> CKRoomSettingsTopicCell! {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsTopicCell.identifier ,
            for: indexPath) as! CKRoomSettingsTopicCell
        
        if self.mxRoom != nil && self.mxRoom?.summary?.topic != nil {
            cell.enableEditTopic(false)
            cell.topicTextLabel.text = self.mxRoom?.summary?.topic
        } else {
            cell.enableEditTopic(true)
        }
        
        return cell
    }

    private func cellForRoomMembers(_ indexPath: IndexPath) -> CKRoomSettingsMembersCell! {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsMembersCell.identifier ,
            for: indexPath) as! CKRoomSettingsMembersCell
        
        return cell
    }

    private func cellforRoomFiles(_ indexPath: IndexPath) -> CKRoomSettingsFilesCell! {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsFilesCell.identifier ,
            for: indexPath) as! CKRoomSettingsFilesCell
        
        return cell
    }

    private func cellForRoomSettings(_ indexPath: IndexPath) -> CKRoomSettingsMoreSettingsCell! {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsMoreSettingsCell.identifier ,
            for: indexPath) as! CKRoomSettingsMoreSettingsCell
        
        return cell
    }

    private func cellForRoomAddPeople(_ indexPath: IndexPath) -> CKRoomSettingsAddPeopleCell! {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsAddPeopleCell.identifier ,
            for: indexPath) as! CKRoomSettingsAddPeopleCell
        
        return cell
    }

    private func cellForRoomLeave(_ indexPath: IndexPath) -> CKRoomSettingsLeaveCell! {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsLeaveCell.identifier ,
            for: indexPath) as! CKRoomSettingsLeaveCell
        return cell
    }
    
    private func showsSettingsEdit() {
        let vc = CKRoomSettingsEditViewController.instance()
        vc.importSession(self.mxSessions)
        vc.mxRoom = self.mxRoom
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showParticiants() {
        
        // initialize vc from xib
        let vc = CKRoomSettingsParticipantViewController.instance()
        
        // import mx session and room id
        vc.importSession(self.mxSessions)
        vc.mxRoom = self.mxRoom

        // push vc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAddingMembers() {
        
        // init
        let vc = CKRoomAddingMembersViewController.instance()
        
        // import session
        vc.importSession(self.mxSessions)
        
        // use mx room
        vc.mxRoom = self.mxRoom
        
        // pus vc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func isInfosAvailableData() -> Bool {
        guard let room = self.mxRoom, let roomSummary = room.summary else {
            return false
        }
        
        return roomSummary.topic != nil
    }
    
    private func showLeaveRoom() {
        
        // alert obj
        let alert = UIAlertController(
            title: "Are you sure to leave room?",
            message: nil,
            preferredStyle: .actionSheet)

        // leave room
        alert.addAction(UIAlertAction(title: "Leave", style: .default , handler:{ (_) in
            
            // spin
            self.startActivityIndicator()
            
            // do leaving room
            if let room = self.mxRoom {
                
                // leave
                room.leave(completion: { (response: MXResponse<Void>) in
                    
                    // main thread
                    DispatchQueue.main.async {
                        
                        // spin
                        self.stopActivityIndicator()
                        
                        // error
                        if let error = response.error {
                            
                            // alert
                            self.showAlert(error.localizedDescription)
                        } else { // ok
                            self.dismiss(animated: false, completion: nil)
                            self.delegate?.roomSettingsDidLeave()
                        }
                    }
                })
            }
        }))
        
        // cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (_) in
        }))
        
        // present
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showMoreSetting() {
        let vc = CKRoomSettingsMoreViewController.instance()
        vc.importSession(self.mxSessions)
        vc.mxRoom = self.mxRoom
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showFiles() {
        let vc = CKRoomSettingsGalleryViewController.instance()
        vc.importSession(self.mxSessions)
        vc.mxRoom = self.mxRoom
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ACTION
    
    @objc func clickedOnBackButton(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - OVERRIDE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Setup close button item
        let closeItemButton = UIBarButtonItem.init(
            image: UIImage(named: "ic_x_close"),
            style: .plain,
            target: self, action: #selector(clickedOnBackButton(_:)))

        // set nv items
        self.navigationItem.leftBarButtonItem = closeItemButton

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = String.ck_LocalizedString(key: "Info")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mxRoom?.summary != nil ? tblSections.count : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = tblSections[section]

        switch sectionType {
        case .infos:
            return self.isInfosAvailableData() ? 3 : 2
        case .settings:
            return 3
        case .actions:
            return self.mxRoom == nil ? 0 : (self.mxRoom.isDirect ? 1: 2)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = tblSections[indexPath.section]
        
        switch sectionType {
        case .infos:
            if indexPath.row == 0 {
                return self.cellForRoomName(indexPath)
            } else if indexPath.row == 1 {
                return self.cellForRoomTopic(indexPath)
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Edit"
                cell.textLabel?.textAlignment = NSTextAlignment.center
                cell.textLabel?.textColor = CKColor.Text.lightBlueText
                return cell
            }
        case .settings:
            if indexPath.row == 0 {
                return self.cellForRoomMembers(indexPath)
            } else if indexPath.row == 1 {
                return self.cellforRoomFiles(indexPath)
            } else if indexPath.row == 2 {
                return self.cellForRoomSettings(indexPath)
            }
            else {
                return UITableViewCell()
            }
        case .actions:
            if mxRoom.isDirect == true {
                return self.cellForRoomLeave(indexPath)
                
            } else {
                if indexPath.row == 0 { return self.cellForRoomAddPeople(indexPath) }
                else if indexPath.row == 1 { return self.cellForRoomLeave(indexPath) }
                else { return UITableViewCell() }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = CKColor.Background.tableView
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CKLayoutSize.Table.header40px
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CKLayoutSize.Table.footer1px
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionType = tblSections[indexPath.section]
        
        // case-in
        switch sectionType {
        case .infos:
            
            // is 2nd row?
            if indexPath.row == 1 {
                
                // fix heigh
                if (self.mxRoom != nil && mxRoom?.summary?.topic == nil) {
                    return CKLayoutSize.Table.row60px
                }

                // dynamic heigh
                return UITableViewAutomaticDimension
            }
        default:
            
            // default
            return CKLayoutSize.Table.row60px
        }
        
        // default
        return CKLayoutSize.Table.row60px
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionType = tblSections[indexPath.section]
        
        switch sectionType {
        case .infos:
            // editting
            if indexPath.row == 1 || indexPath.row == 2 { self.showsSettingsEdit() }
        case .settings:
            // participant
            if indexPath.row == 0 { self.showParticiants() }
            
            // more setting
            else if indexPath.row == 1 { self.showFiles() }
            
            // gallery
            else if indexPath.row == 2 { self.showMoreSetting() }
            break
        case .actions:
            if let room = self.mxRoom {
                if room.isDirect == true {
                    if indexPath.row == 0 { self.showLeaveRoom() }
                } else {
                    if indexPath.row == 0 { self.showAddingMembers() }
                    else if indexPath.row == 1 { self.showLeaveRoom() }
                }
            }
        }
    }
    
    override func initWith(_ session: MXSession!, andRoomId roomId: String!) {
        super.initWith(session, andRoomId: roomId)
        
        if let room = self.mxRoom {
            self.extraEventsListener = room.listen(
            toEventsOfTypes: [kMXEventTypeStringRoomMember]) { (event: MXEvent?, direction: __MXTimelineDirection, roomState: MXRoomState?) in
                self.update(roomState)
            }
        }
    }
    
    override func update(_ newRoomState: MXRoomState!) {
        super.update(newRoomState)
    }
}