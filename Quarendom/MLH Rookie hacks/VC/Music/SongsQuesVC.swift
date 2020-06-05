//
//  SongsQuesVC.swift
//  MLH Rookie hacks
//
//  Created by phani srikar on 05/06/20.
//  Copyright © 2020 phani srikar. All rights reserved.
//

import UIKit
import HCSStarRatingView
import CoreML

struct SongInstance : Decodable
{
    let songId : Int64
    let songName : String
    //let artist : String
    //let  album : String?
    let genres : String
    //let yearOfRelease : String
}
enum SongQuestionsType
{
    case Random
    case GenreBased
}
class SongsQuesVC: UIViewController {

    
    // MARK: References and IBOutlets
    // Song title labels
    @IBOutlet weak var STitle1: UILabel!
    @IBOutlet weak var STitle2: UILabel!
    @IBOutlet weak var STitle3: UILabel!
    @IBOutlet weak var STitle4: UILabel!
    // Move Ratings
    @IBOutlet weak var Song1Rating: HCSStarRatingView!
    @IBOutlet weak var Song2Rating: HCSStarRatingView!
    @IBOutlet weak var Song3Rating: HCSStarRatingView!
    @IBOutlet weak var Song4Rating: HCSStarRatingView!
    @IBOutlet weak var musicBtn: UIButton!
    // Variables
    var sQuesType = SongQuestionsType.Random
//    var results:SongRecommenderOutput?
    var ratingSongsList = [SongInstance]()
    var SelectedMusicGenres : [String]?
    var SongsList = [SongInstance]()
    private var R1Changed : Bool = false
    private var R2Changed : Bool = false
    private var R3Changed : Bool = false
    private var R4Changed : Bool = false
    var SongsRating:[Double] = [Double](repeating: 0, count: 4)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("The selected Genres are : \(SelectedMusicGenres)")

//               SetInitialRatings()
//               DeocodeSongsDataset()
               // Do any additional setup after loading the view.
               Song1Rating.addTarget(self, action: #selector(self.Value1Changed), for: UIControl.Event.valueChanged)
               Song2Rating.addTarget(self, action: #selector(self.Value2Changed), for: UIControl.Event.valueChanged)
               Song3Rating.addTarget(self, action: #selector(self.Value3Changed), for: UIControl.Event.valueChanged)
               Song4Rating.addTarget(self, action: #selector(self.Value4Changed), for: UIControl.Event.valueChanged)
               
               musicBtn.isEnabled = false
               if(sQuesType == .Random){
                   GetRandomSongs(numOfSongs: 4)
               }
               else{
                   GetGenreBasedSongs(numOfSongs: 4)
               }
                   
               STitle1.text = ratingSongsList[0].songName
               STitle2.text = ratingSongsList[1].songName
               STitle3.text = ratingSongsList[2].songName
               STitle4.text = ratingSongsList[3].songName
    }
    
    @IBAction func musicBtnPressed(_ sender: Any) {
          
//          let SongModel = SongsRecommender()
//          let inputs = SongRecommenderInput(items: [ratingSongsList[0].SongId : SongsRating[0],ratingSongsList[1].SongId : SongsRating[1],ratingSongsList[2].SongId : SongsRating[2],ratingSongsList[3].SongId : SongsRating[3]], k: 10, restrict_: [], exclude: [])
//          results = try? SongModel.prediction(input: inputs)
//          print(results?.recommendations)
//          performSegue(withIdentifier: SegueIdentifiers().SongsQuesToSongRecomm, sender: self)
      }
    @IBAction func BackToSongsGVS(_ sender: Any) {
//          performSegue(withIdentifier: SegueIdentifiers().SongQuesToSongsGVS, sender: self)
      }
    
    
    @objc func Value1Changed()
        {
            SongsRating[0] = Double(Float(Song1Rating.value))
    //        print(SongsRating)
            R1Changed = true
            CheckFinalisingSongsInput()
        }
        @objc func Value2Changed()
        {
            SongsRating[1] = Double(Float(Song2Rating.value))
    //        print(SongsRating)
            R2Changed = true
            CheckFinalisingSongsInput()
        }
        @objc func Value3Changed()
        {
            SongsRating[2] = Double(Float(Song3Rating.value))
    //        print(SongsRating)
            R3Changed = true
            CheckFinalisingSongsInput()
        }
        @objc func Value4Changed()
        {
            SongsRating[3] = Double(Float(Song4Rating.value))
    //        print(SongsRating)
            R4Changed = true
            CheckFinalisingSongsInput()
        }
    
    func SetInitialRatings()  {
        SongsRating[0] = Double(Float(Song1Rating.value))
        SongsRating[1] = Double(Float(Song2Rating.value))
        SongsRating[2] = Double(Float(Song3Rating.value))
        SongsRating[3] = Double(Float(Song4Rating.value))
    }
    
    func CheckFinalisingSongsInput()
    {
        if(R1Changed && R2Changed && R3Changed && R4Changed)
        {
            musicBtn.isEnabled = true
            PulseFX()
            print(SongsRating)
        }
    }

    func PulseFX()
    {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        
        pulse.duration = 0.4
        pulse.fromValue = 0.98
        pulse.toValue = 1
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        musicBtn.layer.add(pulse,forKey:nil)
    }
    
       func DeocodeSongsDataset()
        {
            let fileURL = Bundle.main.url(forResource: "SongsDataset", withExtension: "json")!
            let data = try! Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            SongsList = try! decoder.decode([SongInstance].self, from: data)
        }
        
        func GetRandomSongs(numOfSongs : Int)  {
            for _ in 0 ... numOfSongs - 1
            {
                let randNum = Int.random(in: 0..<SongsList.count)
                let songtoSelect = SongsList[randNum]
                ratingSongsList.append(songtoSelect)
            }
        }

        
        func GetGenreBasedSongs(numOfSongs num : Int) {
            if(num <= 0){
                return
            }
            let randNum = Int.random(in: 0..<SongsList.count)
            var simIdx : Float = 0
            let thersholdSimIdx : Float = 0
            let delimiter = "|"
            let newstr = SongsList[randNum].genres
            let songGenres = newstr.components(separatedBy: delimiter)
            let minSimIdx : Float = 1 / Float(SelectedMusicGenres!.count + songGenres.count)
            for sm in 0..<SelectedMusicGenres!.count{
                for gm in 0..<songGenres.count{
    //                print("Selected Genre : \(SelectedGenres![sm]) and MovieGenre : \(movieGenres[gm])")
                    let compStr : String = SelectedMusicGenres![sm]
                    if(compStr == songGenres[gm]){
                        simIdx += (minSimIdx)
                    }
                    else{
                        simIdx += 0
                    }
                }
            }
            if(simIdx > thersholdSimIdx){
                ratingSongsList.append(SongsList[randNum])
                GetGenreBasedSongs(numOfSongs: num - 1)
            }
            else{
                GetGenreBasedSongs(numOfSongs: num)
            }
        }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if(segue.identifier == SegueIdentifiers().SongsQuesToSongRecomm){
//               let destVC = segue.destination as! SongRecommendationVC
//               destVC.finalResults = results?.recommendations as! [Int64]
//        }
    }
    

}
