//
//  ViewController.swift
//  SleepAnalysis
//
//  Created by Anushk Mittal on 5/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import UIKit
import HealthKit


class ViewController: UIViewController {
    
    @IBOutlet var displayTimeLabel: UILabel!
    
    var startTime = NSTimeInterval()
    var timer:NSTimer = NSTimer()
    let healthStore = HKHealthStore()
    var endTime: NSDate!
    var alarmTime: NSDate!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let typestoRead = Set([
            HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!
            ])
        
        let typestoShare = Set([
            HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!
            ])
        
        self.healthStore.requestAuthorizationToShareTypes(typestoShare, readTypes: typestoRead) { (success, error) -> Void in
            if success == false {
                 NSLog(" Display not allowed")
            }
        }
                                }
    
    
    @IBAction func start(sender: AnyObject) {
        alarmTime = NSDate()
        if (!timer.valid) {
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
        
          }
    
    
    @IBAction func stop(sender: AnyObject) {
        endTime = NSDate()
        self.saveSleepAnalysis()
        self.retrieveSleepAnalysis()
        timer.invalidate()
    }
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
       // print(elapsedTime)
      //  print(Int(elapsedTime))
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        displayTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }

    
    func saveSleepAnalysis() {
        
        
    
        if let sleepType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis) {
            
            // we create new object we want to push in Health app
            
            let object = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.InBed.rawValue, startDate: self.alarmTime, endDate: self.endTime)
            
            // we now push the object to HealthStore
            
            healthStore.saveObject(object, withCompletion: { (success, error) -> Void in
                
                if error != nil {
                    
                    // handle the error in your app gracefully 
                    return
                    
                }
                
                if success {
                    print("My new data was saved in Healthkit")
                    
                } else {
                    // It was an error again
                    
                }
                
            })
            
            
            let object2 = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.Asleep.rawValue, startDate: self.alarmTime, endDate: self.endTime)
            
            
            healthStore.saveObject(object2, withCompletion: { (success, error) -> Void in
                
                if error != nil {
                    
                    // handle the error in your app gracefully
                    return
                    
                }
                
                if success {
                    print("My new data (2) was saved in Healthkit")

                } else {
                    // It was an error again
                    
                }
                
            })
            
            
        }

                                }
    
    
    
    
    
    
    func retrieveSleepAnalysis() {
        
        // startDate and endDate are NSDate objects
        
       // ...
        
        // first, we define the object type we want
        
        if let sleepType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis) {
            
            // You may want to use a predicate to filter the data... startDate and endDate are NSDate objects corresponding to the time range that you want to retrieve
            
            //let predicate = HKQuery.predicateForSamplesWithStartDate(startDate,endDate: endDate ,options: .None)
            
            // Get the recent data first
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // the block completion to execute
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // Handle the error in your app gracefully
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            
                            let value = (sample.value == HKCategoryValueSleepAnalysis.InBed.rawValue) ? "InBed" : "Asleep"
                            
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                        }
                    }
                }
            }
            
            
            healthStore.executeQuery(query)
        }
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

