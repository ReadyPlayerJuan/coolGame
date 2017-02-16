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
        static let code = "b1.1.1.1.1,1.0.0.0.1,1.0.0.0.1,1.0.0.-11.1,1.1.1.1.1es1.3ex3.3.0emtestName"
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
