//
//  CKRoomSettingsViewController.swift
//  Riot
//
//  Created by Sinbad Flyce on 1/7/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

protocol CKRoomSettingsViewControllerDelegate: class {
    func roomSettingsDidLeave()
}

@objc class CKRoomSettingsViewController: MXKRoomSettingsViewController {
    
    // MARK: - PROPERTY
    
    /**
     TableView Section Type
     */
    enum TableViewSectionType: Int {
        case editInfo
        case settings
        case actions
        
        static func count() -> Int {
            return 3
        }
    }    
    
    /**
     Moderator permission of room
     */
    private let kModeratorPemission = 50
    
    /**
     delegate
     */
    weak var delegate: CKRoomSettingsViewControllerDelegate?
    
    /**
     tblSections
     */
    private var tblSections: [TableViewSectionType] = [.editInfo, .settings, .actions]
    
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
    
    private var newEditData = (displayRoom: "", topicRoom: "")
    
    private var isCanEdit: Bool = false

    private let disposeBag = DisposeBag()

    // MARK: - CLASS
    
    public override class func nib() -> UINib? {
        return UINib.init(
            nibName: String(describing: CKRoomSettingsViewController.self),
            bundle: Bundle(for: self))
    }
    
    // MARK: - PRIVATE

    private func bindingTheme() {
        // Binding navigation bar color
        themeService.attrsStream.subscribe(onNext: { [weak self] (theme) in
            self?.defaultBarTintColor = themeService.attrs.primaryBgColor
            self?.barTitleColor = themeService.attrs.primaryTextColor
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        themeService.rx
            .bind({ $0.primaryBgColor }, to: view.rx.backgroundColor, tableView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    private func setupTableView()  {
        
        self.tableView.register(CKRoomSettingsRoomNameCell.nib, forCellReuseIdentifier: CKRoomSettingsRoomNameCell.identifier)
        self.tableView.register(CKRoomSettingsTopicCell.nib, forCellReuseIdentifier: CKRoomSettingsTopicCell.identifier)
        self.tableView.register(CKRoomSettingsMembersCell.nib, forCellReuseIdentifier: CKRoomSettingsMembersCell.identifier)
        self.tableView.register(CKRoomSettingsFilesCell.nib, forCellReuseIdentifier: CKRoomSettingsFilesCell.identifier)
        self.tableView.register(CKRoomSettingsMoreSettingsCell.nib, forCellReuseIdentifier: CKRoomSettingsMoreSettingsCell.identifier)
        self.tableView.register(CKRoomSettingsAddPeopleCell.nib, forCellReuseIdentifier: CKRoomSettingsAddPeopleCell.identifier)
        self.tableView.register(CKRoomSettingsLeaveCell.nib, forCellReuseIdentifier: CKRoomSettingsLeaveCell.identifier)
        self.tableView.register(CKRoomSettingsLeaveCell.nib, forCellReuseIdentifier: CKRoomSettingsLeaveCell.identifier)
        self.tableView.register(CKEditRoomSettingsCell.nib, forCellReuseIdentifier: CKEditRoomSettingsCell.identifier)
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.separatorColor = .clear
        
        self.reloadTableView()
    }
    
    private func reloadTableView() {
        tblSections = [.editInfo, .settings, .actions]
        tableView.reloadData()
    }
    
    private func reflectDataUI() {
        self.tableView.reloadData()
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
    
    /**
     This func to make sure room info is available
     */
    private func isInfoCanEdit() -> Bool {
        
        // room object is not existing
        guard let room = self.mxRoom, let _ = room.summary else {
            return false
        }
        
        // power levels
        let pl = self.mxRoomState?.powerLevels?.powerLevelOfUser(
            withUserID: self.mainSession?.myUser?.userId) ?? 0

        if pl < kModeratorPemission { return false }
        
        return true
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
        MXKRoomDataSource.load(withRoomId: self.mxRoom.roomId, andMatrixSession: self.mxRoom.mxSession) { (roomDataSource) in
            if let roomDataSource = roomDataSource as? MXKRoomDataSource {
                //roomDataSource.filterMessagesWithURL = true
                roomDataSource.finalizeInitialization()
                let vc = CKRoomFilesViewController.instance()
                vc.hasRoomDataSourceOwnership = true
                vc.displayRoom(roomDataSource)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                print("")
            }
        }
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

        self.bindingTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = String.ck_LocalizedString(key: "Info")
        self.navigationController?.navigationBar.titleTextAttributes = themeService.attrs.navTitleTextAttributes
        self.reloadTableView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mxRoom?.summary != nil ? tblSections.count : 0
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

// MARK: Tableview Delegate
extension CKRoomSettingsViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = CKRoomHeaderInSectionView.instance()
        v?.descriptionLabel.text = nil
        v?.theme.backgroundColor = themeService.attrStream{ $0.primaryBgColor }
        return v
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let sectionType = TableViewSectionType(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .editInfo:
            return CGFloat.leastNonzeroMagnitude
        default:
            return CKLayoutSize.Table.defaultHeader
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionType = tblSections[indexPath.section]
        
        // case-in
        switch sectionType {
        case .editInfo:
            return UITableViewAutomaticDimension
        case .actions:
            return CKLayoutSize.Table.row60px
        case .settings:
            return CKLayoutSize.Table.row43px
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionType = tblSections[indexPath.section]
        
        switch sectionType {
        case .editInfo:
            break
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
}


// MARK: Tableview Datasource
extension CKRoomSettingsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = tblSections[section]

        switch sectionType {
        case .editInfo:
            return 1
        case .settings:
            return 3
        case .actions:
            return self.mxRoom == nil ? 0 : (self.mxRoom.isDirect ? 1: 2)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = tblSections[indexPath.section]
        
        switch sectionType {
        case .editInfo:
            return cellForEditRoomDetail(indexPath)
        case .settings:
            if indexPath.row == 0 {
                return cellForSettingDetail(indexPath: indexPath, icon: #imageLiteral(resourceName: "member_edit_detail_room"), title: "room_details_people")
            } else if indexPath.row == 1 {
                return cellForSettingDetail(indexPath: indexPath, icon: #imageLiteral(resourceName: "file_edit_detail_room"), title: "room_details_files")
            } else if indexPath.row == 2 {
                return cellForSettingDetail(indexPath: indexPath, icon: #imageLiteral(resourceName: "setting_edit_detail_room"), title: "room_details_settings")
            }
            else {
                return UITableViewCell()
            }
        case .actions:
            if mxRoom.isDirect == true {
                return self.cellForRoomLeave(indexPath)
            } else {
                if indexPath.row == 0 {
                    return cellForSettingDetail(indexPath: indexPath, icon: #imageLiteral(resourceName: "add_people_edit_detail_room"), title: "add_people_room_detail")
                } else if indexPath.row == 1 {
                    return self.cellForRoomLeave(indexPath)
                } else {
                    return UITableViewCell()
                }
            }
        }
    }
}

extension CKRoomSettingsViewController {
    
    private func requestEditRoomDetail(displayName: String, topicRoom: String) {
        
        self.showSpinner()
        
        guard let room = self.mxRoom else {
            self.removeSpinner()
            return
        }
        
        // -- displayName
        room.summary.displayname = displayName
        room.setName(displayName) { response in
            
            self.removeSpinner()
            
            if let error = response.error {
                self.showAlert(error.localizedDescription)
            }
        }
        
        // -- topicName
        room.summary.topic = topicRoom
        room.setTopic(topicRoom) { response in
            self.removeSpinner()
            if let error = response.error {
                self.showAlert(error.localizedDescription)
            }
        }
    }
}

// MARK: Custom Cell
extension CKRoomSettingsViewController {
    
    private func cellForEditRoomDetail(_ indexPath: IndexPath) -> CKEditRoomSettingsCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CKEditRoomSettingsCell.identifier, for: indexPath) as! CKEditRoomSettingsCell
        
        let pl = self.mxRoomState?.powerLevels?.powerLevelOfUser(withUserID: self.mainSession?.myUser?.userId) ?? 0
        
        if !isCanEdit {
            isCanEdit = pl >= kModeratorPemission
        }
        
        cell.isAdminEdit = pl >= kModeratorPemission || isCanEdit

        cell.bindingData(mxRoom: self.mxRoom, mxRoomState: self.mxRoomState)
        
        cell.editAvatarHandler = {
            
        }
        
        cell.onSaveHandler = { (displayRoom, topicName) in
            self.view.endEditing(true)
            self.requestEditRoomDetail(displayName: displayRoom, topicRoom: topicName)
        }
        
        return cell
    }

    private func cellForRoomLeave(_ indexPath: IndexPath) -> CKRoomSettingsLeaveCell! {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsLeaveCell.identifier ,
            for: indexPath) as! CKRoomSettingsLeaveCell
        
        cell.theme.backgroundColor = themeService.attrStream{ $0.primaryBgColor }

        return cell
    }
    
    
    // general cell setting detail
    
    private func cellForSettingDetail(indexPath: IndexPath, icon: UIImage?, title: String?) -> CKRoomSettingsMoreSettingsCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CKRoomSettingsMoreSettingsCell.identifier ,
            for: indexPath) as! CKRoomSettingsMoreSettingsCell

        cell.imageSettings.image = icon?.withRenderingMode(.alwaysTemplate)
        cell.imageSettings.contentMode = .scaleAspectFit
        cell.imageSettings.theme.tintColor = themeService.attrStream{ $0.primaryTextColor }
        cell.btnSetting.setTitle(CKLocalization.string(byKey: title ?? ""), for: .normal)
        cell.btnSetting.theme.titleColor(from: themeService.attrStream{ $0.primaryTextColor }, for: .normal)
        cell.theme.backgroundColor = themeService.attrStream{ $0.primaryBgColor }
        
        return cell
    }
}
