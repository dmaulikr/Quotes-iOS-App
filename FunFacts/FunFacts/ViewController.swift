//
//  ViewController.swift
//  FunFacts
//
//  Created by Chirag Aswani on 7/14/17.
//  Copyright © 2017 Chig Apps. All rights reserved.
//

import UIKit
import GameKit
import AVFoundation
import GoogleMobileAds
import FirebaseDatabase
import SDWebImage

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5;
    }
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate, UIApplicationDelegate{
    
    //IBOutlets
    @IBOutlet weak var quoteType: UILabel!
    @IBOutlet weak var FunFactLabel: UILabel!
    @IBOutlet weak var factType: UIPickerView!
    @IBOutlet weak var backDrop: UIView!
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var myBanner: GADBannerView!
    
    
    //Speech Constant
    let speech = AVSpeechSynthesizer()
    
    //Picker View Categories
    var factCategory = ["Quote of the Day", "Funny Quotes", "Inspiring Quotes", "Famous Quotes", "Random Facts", "Random Pictures"]
    var category: String = "Quote of the Day"
    
    //POST Data from Firebase
    var quote_day: [String] = []
    var funny_quotes: [String] = []
    var inspiring_quotes: [String] = []
    var famous_quotes: [String] = []
    var random_facts: [String] = []
    var random_pictures: [URL] = []
    
    //Saved Quotes from Swipes
    var savedFunnyQuotes: [Int] = []
    var savedInspiringQuotes: [Int] = []
    var savedFamousQuotes: [Int] = []
    var savedFacts: [Int] = []
    var savedPictures: [Int] = []
    
    //Firebase Variables
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    //AVSpeech Synthesizer Action
    @IBAction func play() {
        if speech.isSpeaking == true{
            speech.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
            let speechFact = AVSpeechUtterance(string: FunFactLabel.text!)
            speech.speak(speechFact)
        } else {
            let speechFact = AVSpeechUtterance(string: FunFactLabel.text!)
            speech.speak(speechFact)
        }
        
    }
    
    //Share Current FunFact Label
    @IBAction func sharePressed(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [FunFactLabel.text], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    //Displays Next Fact
    @IBAction func nextFact(_ sender: UISwipeGestureRecognizer) {
            activityIndicator.stopAnimating()
            let randomPicture = GKRandomSource.sharedRandom().nextInt(upperBound: self.random_pictures.count)
            frontImage.sd_setImage(with: self.random_pictures[randomPicture])
            if (category == "Funny Quotes"){
                let randomNum = GKRandomSource.sharedRandom().nextInt(upperBound: self.funny_quotes.count)
                quoteType.text = category
                FunFactLabel.text = self.funny_quotes[randomNum]
                savedFunnyQuotes.append(randomNum)
                
            }
            if (category == "Inspiring Quotes"){
                let randomNum = GKRandomSource.sharedRandom().nextInt(upperBound: self.inspiring_quotes.count)
                quoteType.text = category
                FunFactLabel.text = self.inspiring_quotes[randomNum]
                savedInspiringQuotes.append(randomNum)
            }
            if (category == "Famous Quotes"){
                let randomNum = GKRandomSource.sharedRandom().nextInt(upperBound: self.famous_quotes.count)
                quoteType.text = category
                FunFactLabel.text = self.famous_quotes[randomNum]
                savedFamousQuotes.append(randomNum)
            }
            if (category == "Random Facts"){
                let randomNum = GKRandomSource.sharedRandom().nextInt(upperBound: self.random_facts.count)
                quoteType.text = category
                FunFactLabel.text = self.random_facts[randomNum]
                savedFacts.append(randomNum)
            }
            if (category == "Quote of the Day"){
                quoteType.text = category
                FunFactLabel.text = self.quote_day[self.quote_day.count-1]
            }
        
        
    }
    
    //Displays the Previous Fact or Quote
    @IBAction func previousFact(_ sender: UISwipeGestureRecognizer) {
        let randomPicture = GKRandomSource.sharedRandom().nextInt(upperBound: self.random_pictures.count)
        
        if (category == "Funny Quotes" && savedFunnyQuotes.count >= 1){
            FunFactLabel.text = funny_quotes[savedFunnyQuotes[savedFunnyQuotes.count-1]]
            frontImage.sd_setImage(with: self.random_pictures[randomPicture])
            savedFunnyQuotes.removeLast()
        }
        else if (category == "Inspiring Quotes" && savedInspiringQuotes.count >= 1){
            savedInspiringQuotes.removeLast()
            FunFactLabel.text = inspiring_quotes[savedInspiringQuotes[savedInspiringQuotes.count-1]]
            frontImage.sd_setImage(with: self.random_pictures[randomPicture])
            
        }
        else if (category == "Famous Quotes" && savedFamousQuotes.count != 1){
            savedFamousQuotes.removeLast()
            FunFactLabel.text = famous_quotes[savedFamousQuotes[savedFamousQuotes.count-1]]
            frontImage.sd_setImage(with: self.random_pictures[randomPicture])
        }
        else if (category == "Random Facts" && savedFacts.count != 1){
            savedFacts.removeLast()
            FunFactLabel.text = random_facts[savedFacts[savedFacts.count-1]]
            frontImage.sd_setImage(with: self.random_pictures[randomPicture])
        }
        else if (category == "Quote of the Day"){
            FunFactLabel.text = self.quote_day[self.quote_day.count-1]
        }
        else {
            FunFactLabel.text = "Swipe Right for More!"
            frontImage.image = UIImage(named: "2")
        }
    }
    
    //Immediately Pulls Data from Firebase
    override func viewDidLoad() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        ref = Database.database().reference()
        for category in factCategory{
            databaseHandle = ref?.child(category).observe(.childAdded, with: { (snapshot) in
                let post = snapshot.value as? String
                if let actualPost = post{
                    if category == "Quote of the Day"{
                        self.quote_day.append(actualPost)
                    }
                    else if category == "Funny Quotes"{
                        self.funny_quotes.append(actualPost)
                    }
                    else if category == "Inspiring Quotes"{
                        self.inspiring_quotes.append(actualPost)
                    }
                    else if category == "Random Facts"{
                        self.random_facts.append(actualPost)
                    }
                    else if category == "Random Pictures"{
                        self.random_pictures.append(URL(string: actualPost)!)
                    }
                    else {
                        self.famous_quotes.append(actualPost)
                    }
                }
            })
        }
        
        //Google Ad Mob
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        myBanner.adUnitID = "ca-app-pub-1767343694152590/8138691547"
        myBanner.rootViewController = self
        myBanner.delegate = self
        myBanner.load(request)
        
        //Style Pre-sets
        FunFactLabel.text = ""
        factType.delegate = self
        factType.dataSource = self
        self.view.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        backDrop.dropShadow()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return factCategory.count-1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return factCategory[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category = factCategory[row]
    }
    
}



