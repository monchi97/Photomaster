//
//  ViewController.swift
//  PhotoMaster
//
//  Created by x16069xx on 2016/06/11.
//  Copyright © 2016年 Shimon. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func precentPickerController(sourceType: UIImagePickerControllerSourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let picker = UIImagePickerController()
            
            picker.sourceType = sourceType
            
            picker.delegate = self
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        photoImageView.image = image
    }
    
    @IBAction func selectButtonTapped(sender: UIButton) {
   
        let alertController = UIAlertController(title: "画像の取得先を選択", message: nil, preferredStyle: .ActionSheet)
        
        let firstAction = UIAlertAction(title: "カメラ", style: .Default) {
            action in
            self.precentPickerController(.Camera)
        }
        
        let secondAction = UIAlertAction(title: "アルバム", style: .Default) {
            action in
            self.precentPickerController(.PhotoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        //アラートを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //テキストの合成
    func drawText(image: UIImage) -> UIImage {
        //テキストの内容
        let text = "Life is Tech!\nLeaders 8th"
        
        //グラフィックコンテキストの生成、編集を開始
        UIGraphicsBeginImageContext(image.size)
        
        //読み込んだ写真を書き出す
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        //書き出す位置と大きさの設定
        let textRect = CGRectMake(5, 5, image.size.width - 5, image.size.height - 5)
        
        //テキストの特性（フォント、カラー、スタイル）の設定
        let textFontAttributes = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(120),
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSParagraphStyleAttributeName: NSMutableParagraphStyle.defaultParagraphStyle()
        ]
        
        //指定範囲にテキストを描写
        text.drawInRect(textRect, withAttributes: textFontAttributes)
        
        //グラフィックコンテキストの画像を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //グラフィックコンテキストの編集を終了
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //元の画像にマスク画像を合成するメゾット
    func drawMaskImage(image: UIImage) -> UIImage {
        //グラフィックコンテキストの生成、編集を開始
        UIGraphicsBeginImageContext(image.size)
        
        //読み込んだ写真を書き出す
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        //マスク画像
        let maskImage = UIImage(named: "lifeistech_logo_1280x720")
        
        //描き出す位置と大きさの設定
        let offset: CGFloat = 50.0
        let maskRect = CGRectMake(
            image.size.width - maskImage!.size.width - offset,
            image.size.height - maskImage!.size.height - offset,
            maskImage!.size.width, maskImage!.size.height)
        
        //指定範囲に画像を描写
        maskImage!.drawInRect(maskRect)
        
        //グラフィックコンテキストの取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //グラフィックコンテキストの編集を終了
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //アラートのメゾット
    func simpleAlert(titleString: String) {
        
        let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func processButtonTapped(sender: UIButton) {
        guard let selectedPhoto = photoImageView.image else {
            simpleAlert("画像がありません")
            return
        }
        //選択肢のタイトル、メッセージ、アラートタイプの設定
        let alertController = UIAlertController(title: "合成するパーツを選択", message: nil, preferredStyle: .ActionSheet)
        
        //選択肢の名前と処理
        let firstAction = UIAlertAction(title: "テキスト", style: .Default) {
            action in
            
            self.photoImageView.image = self.drawText(selectedPhoto)
        }
        let secondAction = UIAlertAction(title: "LiT!ロゴ", style: .Default) {
            action in
            
            self.photoImageView.image = self.drawMaskImage(selectedPhoto)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        //選択肢をアラートに登録
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        //選択肢を表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func postToSNS(serviceType: String) {
        
        let myComposeView = SLComposeViewController(forServiceType: serviceType)
        
        myComposeView.setInitialText("PhotoMasterからの投稿！")
        
        myComposeView.addImage(photoImageView.image)
        
        self.presentViewController(myComposeView, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonTapped(sender: UIButton) {
        guard let selectedPhoto = photoImageView.image else {
            simpleAlert("画像がありません")
            return
        }
        
        let alertController = UIAlertController(title: "アップロード先を選択", message: nil, preferredStyle: .ActionSheet)
        
        let firstAction = UIAlertAction(title: "Facebookに投稿", style: .Default) {
            action in
            
            self.postToSNS(SLServiceTypeFacebook)
        }
        let secondAction = UIAlertAction(title: "Twitterに投稿", style: .Default) {
            action in
            
            self.postToSNS(SLServiceTypeTwitter)
        }
        let thirdAction = UIAlertAction(title: "カメラロールに保存", style: .Default) {
            action in
            UIImageWriteToSavedPhotosAlbum(selectedPhoto, self, nil, nil)
            self.simpleAlert("アルバムに保存されました")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(thirdAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

