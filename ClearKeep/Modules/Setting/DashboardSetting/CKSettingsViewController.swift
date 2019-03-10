//
//  CKSettingsViewController.swift
//  Riot
//
//  Created by Pham Hoa on 3/7/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import UIKit

final class CKSettingsViewController: MXKViewController {

    // MARK: - Enums
    
    private enum GroupedSettingType {
        case profile
        case notification
        case calls
        case report
        case security
        case terms
        case privacyPolicy
        case copyright
        case markAllMessageAsRead
        case clearCache
        case deactivateAccount
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    // MARK: Private
    
    private var tblDatasource: [[GroupedSettingType]] = [[]]
    
    // MARK: Public
    
    weak var deactivateAccountViewController: DeactivateAccountViewController?
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Setting"
    }
    
    private func setupInitization() {
        // Init datasource
        tblDatasource = [[.profile], [.notification, .calls, .report], [.security], [.terms, .privacyPolicy, .copyright], [.markAllMessageAsRead, .clearCache], [.deactivateAccount]]
        setupTableView()
    }
}

// MARK: - Private Methods

private extension CKSettingsViewController {
    func setupTableView() {
        tableView.register(UINib.init(nibName: "CKSettingsGroupedItemCell", bundle: Bundle.init(for: CKSettingsGroupedItemCell.self)), forCellReuseIdentifier: "CKSettingsGroupedItemCell")
        tableView.register(UINib.init(nibName: "CKSettingButtonCell", bundle: Bundle.init(for: CKSettingButtonCell.self)), forCellReuseIdentifier: "CKSettingButtonCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // style
    }
    
    // cells
    
    func cellForButton(_ tableView: UITableView, indexPath: IndexPath) -> CKSettingButtonCell {
        let cellType = tblDatasource[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CKSettingButtonCell", for: indexPath) as! CKSettingButtonCell

        switch cellType {
        case .markAllMessageAsRead:
            cell.titleLabel.textColor = kRiotColorGreen
            cell.titleLabel.text =  NSLocalizedString("settings_mark_all_as_read", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
        case .clearCache:
            cell.titleLabel.textColor = kRiotColorGreen
            cell.titleLabel.text =  NSLocalizedString("settings_clear_cache", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
        case .deactivateAccount:
            cell.titleLabel.textColor = kRiotColorRed
            cell.titleLabel.text =  NSLocalizedString("settings_deactivate_my_account", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
        default:
            break
        }
        
        return cell
    }
    
    func cellForNormalItems(_ tableView: UITableView, indexPath: IndexPath) -> CKSettingsGroupedItemCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CKSettingsGroupedItemCell", for: indexPath) as! CKSettingsGroupedItemCell
        
        let cellType = tblDatasource[indexPath.section][indexPath.row]
        switch cellType {
        case .profile:
            cell.titleLabel.text = "Edit Profile"
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_edit_profile_setting")
        case .notification:
            cell.titleLabel.text = "Notification"
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_notification_setting")
        case .calls:
            cell.titleLabel.text = "Calls"
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_calls_setting")
        case .security:
            cell.titleLabel.text = "Security"
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_security_setting")
        case .terms:
            cell.titleLabel.text = NSLocalizedString("settings_term_conditions", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_terms_condition_setting")
        case .privacyPolicy:
            cell.titleLabel.text = NSLocalizedString("settings_privacy_policy", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_privacy_policy_setting")
        case .report:
            cell.titleLabel.text = "Report"
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_report_setting")
        case .copyright:
            cell.titleLabel.text = NSLocalizedString("settings_copyright", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_copyright_setting")
        default:
            break
        }
        
        return cell
    }
    
    // actions
    
    func deactivateAccountAction() {
        if let deactivateAccountViewController = DeactivateAccountViewController.instantiate(withMatrixSession: self.mainSession) {
            let navigationController = UINavigationController(rootViewController: deactivateAccountViewController)
            navigationController.modalPresentationStyle = .formSheet
            
            present(navigationController, animated: true)
            
            deactivateAccountViewController.delegate = self
            
            self.deactivateAccountViewController = deactivateAccountViewController
        } else {
            self.deactivateAccountViewController = nil
        }
    }
    
    func showWebViewController(url: String, title: String) {
        if let webViewViewController = WebViewViewController(url: url) {
            webViewViewController.title = title

            // Hide back button title
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

            navigationController?.pushViewController(webViewViewController, animated: true)
        }
    }
    
    func markAllAsRead(cell: UITableViewCell) {
        // Feedback: disable button and run activity indicator
        cell.isUserInteractionEnabled = false
        cell.alpha = 0.7
        
        startActivityIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            
            AppDelegate.the().markAllMessagesAsRead()
            
            self.stopActivityIndicator()
            
            cell.isUserInteractionEnabled = true
            cell.alpha = 1.0
        })
    }
    
    func clearCache(cell: UITableViewCell) {
        // Feedback: disable button and run activity indicator
        cell.isUserInteractionEnabled = false
        cell.alpha = 0.7
        
        startActivityIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            AppDelegate.the().reloadMatrixSessions(true)
        })
    }
}

// MARK: - Public Methods

extension CKSettingsViewController {
    
}

// MARK: UITableViewDataSource

extension CKSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tblDatasource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tblDatasource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = tblDatasource[indexPath.section][indexPath.row]
        switch cellType {
        case .deactivateAccount, .markAllMessageAsRead, .clearCache:
            return cellForButton(tableView, indexPath: indexPath)
        default:
            return cellForNormalItems(tableView, indexPath: indexPath)
        }
    }
}

// MARK: UITableViewDelegate

extension CKSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellType = tblDatasource[indexPath.section][indexPath.row]
        switch cellType {
        case .profile:
            let vc = CKAccountProfileEditViewController.instance()
            vc.importSession(self.mxSessions)
            self.navigationController?.pushViewController(vc, animated: true)
        case .notification:
            let vc = CKNotificationSettingViewController.instance()
            vc.importSession(self.mxSessions)
            self.navigationController?.pushViewController(vc, animated: true)
        case .calls:
            let vc = CKCallsSettingViewController.instance()
            vc.importSession(self.mxSessions)
            self.navigationController?.pushViewController(vc, animated: true)
        case .security:
            let vc = CKSecuritySettingViewController.instance()
            vc.importSession(self.mxSessions)
            self.navigationController?.pushViewController(vc, animated: true)
        case .report:
            let vc = CKReportSettingViewController.instance()
            vc.importSession(self.mxSessions)
            self.navigationController?.pushViewController(vc, animated: true)
        case .terms:
            let url = NSLocalizedString("settings_term_conditions_url", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            let title = NSLocalizedString("settings_term_conditions", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            
            self.showWebViewController(url: url, title: title)
        case .privacyPolicy:
            let url = NSLocalizedString("settings_privacy_policy_url", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            let title = NSLocalizedString("settings_privacy_policy", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            
            self.showWebViewController(url: url, title: title)
        case .copyright:
            let url = NSLocalizedString("settings_copyright_url", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            let title = NSLocalizedString("settings_copyright", tableName: "Vector", bundle: Bundle.main, value: "", comment: "")
            
            self.showWebViewController(url: url, title: title)
        case .deactivateAccount:
            self.deactivateAccountAction()
        case .markAllMessageAsRead:
            if let cell = tableView.cellForRow(at: indexPath) {
                self.markAllAsRead(cell: cell)
            }
        case .clearCache:
            if let cell = tableView.cellForRow(at: indexPath) {
                self.clearCache(cell: cell)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CKLayoutSize.Table.row43px
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let numberOfSections = tableView.numberOfSections
        if section == numberOfSections - 1 {
            let label = UILabel.init()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor.init(red: 84/255, green: 84/255, blue: 84/255, alpha: 0.7)
            
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
            
            label.text = "Version \(version) (\(build))"
            
            let footerView = UIView.init()
            footerView.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                footerView.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -15),
                footerView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 15),
                footerView.topAnchor.constraint(equalTo: label.topAnchor, constant: -20),
                footerView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
                ])
            
            return footerView
        }
        
        return nil
    }
}

// MARK: - DeactivateAccountViewControllerDelegate

extension CKSettingsViewController: DeactivateAccountViewControllerDelegate {
    func deactivateAccountViewControllerDidCancel(_ deactivateAccountViewController: DeactivateAccountViewController!) {
        deactivateAccountViewController.dismiss(animated: true, completion: nil)
    }
    
    func deactivateAccountViewControllerDidDeactivate(withSuccess deactivateAccountViewController: DeactivateAccountViewController!) {
        print("[SettingsViewController] Deactivate account with success")


        AppDelegate.the().logoutSendingRequestServer(false) { isLoggedOut in
            print("[SettingsViewController] Complete clear user data after account deactivation")
        }
    }
}