//
//  ImakokoViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/03/31.
//  Copyright (c) 2016年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Parse
import SpriteKit
import MBProgressHUD
import GoogleMobileAds

extension GoNowViewController: TransisionProtocol {}

class GoNowViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UINavigationControllerDelegate,
    UIPickerViewDelegate,
    PickerViewControllerDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var inputDateFrom = Date()
    var inputDateTo = Date()
    var inputPlace = ""
    var inputChar = ""
    var palGeoPoint: PFGeoPoint?
    
    let normalTableViewCellIdentifier = "NormalCell"
    let detailTableViewCellIdentifier = "DetailCell"
    
    let targetProfileItems = ["待ち合わせ開始時間", "待ち合わせ終了時間", "待ち合わせ場所", "自分の特徴"]
    
    var _interstitial: GADInterstitial?
    
    var selectedRow: Int = 0
    
    override func loadView() {
        if let view = UINib(nibName: "ImakokoView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "場所と特徴を登録"
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        tableView.register(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        
        // 不要行の削除
        let noCreateView = UIView(frame: CGRect.zero)
        noCreateView.backgroundColor = UIColor.clear
        tableView.tableFooterView = noCreateView
        tableView.tableHeaderView = noCreateView
        view.addSubview(tableView)
        
        if isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
            _interstitial = self.showFullAdmob()
        }
    }
    
    /*
    セクションの数を返す.
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targetProfileItems.count
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        var normalCell: UITableViewCell?
        var detailCell: DetailProfileTableViewCell?
        
        let tableViewCellIdentifier = "Cell"
        
        if indexPath.row == 0 || indexPath.row == 1 {
            normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
            if normalCell == nil {
                normalCell = UITableViewCell(style: .value1, reuseIdentifier: tableViewCellIdentifier)
                normalCell!.textLabel!.font = UIFont.systemFont(ofSize: 16)
                normalCell!.detailTextLabel!.font = UIFont.systemFont(ofSize: 16)
            }
            
        } else {
           detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
        }

        if indexPath.row == 0 {
            normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
            let formatDateString = dateFormatter.string(from: self.inputDateFrom)
            normalCell?.detailTextLabel?.text = formatDateString
            
            cell = normalCell
            
        } else if indexPath.row == 1 {
            normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
            let formatDateString = dateFormatter.string(from: self.inputDateTo)
            normalCell?.detailTextLabel?.text = formatDateString
            
            cell = normalCell
        
        } else if indexPath.row == 2 {
            detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
            if inputPlace.isEmpty {
                detailCell?.valueLabel.text = "待ち合わせする場所を詳細に書いてください。性と関連した内容、金銭関連の内容、その他不適切な内容を作成する場合、アカウントが停止される可能性がありますのでご注意ください"
            } else {
                detailCell?.valueLabel.text = self.inputPlace
            }
            
            cell = detailCell
            
        } else if indexPath.row == 3 {
            detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
            if inputChar.isEmpty {
                detailCell?.valueLabel.text = "自分の服装など、待ち合わせの際に分かる情報を書いてください。性と関連した内容、金銭関連の内容、その他不適切な内容を作成する場合、アカウントが停止される可能性がありますのでご注意ください"
            } else {
                detailCell?.valueLabel.text = self.inputChar
            }
            
            cell = detailCell
        }
        
        return cell!
    }
    
//    // PickerViewController より性別を選択した際に実行される処理
//    internal func setGender(selectedIndex: Int,selected: String) {
//    }
//    
//    // PickerViewController より年齢を選択した際に実行される処理
//    internal func setAge(selectedIndex: Int,selected: String) {
//    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setSelectedValue(_ selectedIndex: Int, selectedValue: String, type: SelectPickerType) {
    }
    
    internal func setInputValue(_ inputValue: String, type: InputPickerType) {
        if type == .comment {
            if selectedRow == 1 {
                self.inputPlace = inputValue

            } else if selectedRow == 2 {
                self.inputChar = inputValue
            }
            
            tableView.reloadData()
        }
    }
    
    internal func setSelectedDateFrom(_ selectedDate: Date) {
        if selectedRow == 0 {
            self.inputDateFrom = selectedDate
        }
    }
    
    internal func setSelectedDateTo(_ selectedDate: Date) {
        if selectedRow == 1 {
            self.inputDateTo = selectedDate
        }
    }
    
    
//    // PickerViewController よりを保存ボタンを押下した際に実行される処理
//    internal func setComment(comment: String) {
//        if selectedRow == 0 {
//            self.inputDate = comment
//            
//        } else if selectedRow == 1 {
//            self.inputPlace = comment
//            
//        } else if selectedRow == 2 {
//            self.inputChar = comment
//        }
//        
//        // テーブル再描画
//        tableView.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50
            
        } else {
            return 120
        }
    }
    
    // セルがタップされた時
    internal func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        
        let vc = PickerViewController()
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                vc.palKind = "imakokoDateFrom"

                vc.palInput = inputDateFrom as AnyObject
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
                vc.palKind = "imakokoDateTo"
                vc.palInput = inputDateTo as AnyObject
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 2 {
                vc.palKind = "imakoko"
                vc.palInput = inputPlace as AnyObject
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 3 {
                vc.palKind = "imakoko"
                vc.palInput = inputChar as AnyObject
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        selectedRow = indexPath.row
    }
    
    @IBAction func imaikuButton(_ sender: AnyObject) {
        
        MBProgressHUDHelper.show("Loading...")
        
        var userInfo = PersistentData.User()
        
        ParseHelper.getMyUserInfomation(userInfo.userID) { (error: NSError?, result: PFObject?) -> Void in
            
            guard error == nil else {
                return
            }
            
            let query = result! as PFObject
            query["GPS"] = self.palGeoPoint
            query["MarkTime"] = self.inputDateFrom
            //TODO
            query["MarkTimeTo"] = self.inputDateTo
            query["PlaceDetail"] = self.inputPlace
            query["MyChar"] = self.inputChar
            query["IsRecruitment"] = true
            
            query.saveInBackground { (success: Bool, error: Error?) -> Void in
                defer {
                    MBProgressHUDHelper.hide()
                }
                
                guard error == nil else {
                    return
                }
                
                //local db に保存
                var userData = PersistentData.User()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                let formatDateString = dateFormatter.string(from: self.inputDateFrom)
                userData.insertTime = formatDateString
                
                userData.place = self.inputPlace
                userData.mychar = self.inputChar
                userData.isRecruitment = true //募集中フラグ
                
                UIAlertController.showAlertView("", message: "現在位置を登録しました") { action in
                    if self._interstitial!.isReady {
                        self._interstitial!.present(fromRootViewController: self)
                    }
                    
                    self.navigationController!.popToRootViewController(animated: true)
                }
            }
        }

    }

}
