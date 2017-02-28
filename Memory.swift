//
//  Memory.swift
//  coolGame
//
//  Created by Nick Seel on 2/13/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation

class Memory {
    struct stageEdit {
        static let code = Stage.defaultStage
        static let currentStageID = "-1"
        static let abilityUnlockProgress = "0"
    }
    
    class func saveAbilityUnlockProgress(progress: Int) {
        let defaults = UserDefaults.standard
        
        defaults.setValue(progress, forKey: stageEdit.abilityUnlockProgress)
        defaults.synchronize()
    }
    
    class func getAbilityUnlockProgress() -> Int {
        let defaults = UserDefaults.standard
        
        if let progress = defaults.string(forKey: stageEdit.abilityUnlockProgress) {
            return progress.toInt()!
        }
        
        return -1
    }
    
    class func saveCurrentStageID(ID: Int) {
        let defaults = UserDefaults.standard
        
        defaults.setValue(ID, forKey: stageEdit.currentStageID)
        defaults.synchronize()
    }
    
    class func getCurrentStageID() -> Int {
        let defaults = UserDefaults.standard
        
        if let ID = defaults.string(forKey: stageEdit.currentStageID) {
            return ID.toInt()!
        }
        
        return -1
    }
    
    class func saveStageEdit(code: String) {
        let defaults = UserDefaults.standard
        
        defaults.setValue(code, forKey: stageEdit.code)
        defaults.synchronize()
    }
    
    class func getStageEdit() -> String {
        let defaults = UserDefaults.standard
    
        if let stringOne = defaults.string(forKey: stageEdit.code) {
            return stringOne
        }
        
        return "no stage"
    }
}
