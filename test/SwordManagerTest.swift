//
//  SwordManagerTest.swift
//  ObjCSword
//
//  Created by Manfred Bergmann on 02.03.16.
//
//

import Foundation
import XCTest

class SwordManagerTest: XCTestCase {

    var mgr: SwordManager?

    override func setUp() {
        super.setUp()
        
        let modulesDir = Bundle(for:type(of: self)).resourcePath!.appending("/TestModules")
        NSLog("modulesDir: \(modulesDir)")
        
        Configuration.config(withImpl: OSXConfiguration())
        FilterProviderFactory.factory().initWithImpl(DefaultFilterProvider())
        mgr = SwordManager(path:modulesDir)
    }
    
    func testAvailableModules() {
        XCTAssert(mgr != nil)
        XCTAssert((mgr?.allModules().count)! > 0)
        NSLog("modules: \(mgr?.allModules().count ?? -1)")
    }
    
    func testGetModule() {
        let mod = mgr?.module(withName: "kjv")
        XCTAssert(mod != nil)
        XCTAssert(mod?.name() == "KJV")
    }

    func testReload() {
        var mod = mgr?.module(withName: "kjv")
        
        mgr?.reload()
        mod = mgr?.module(withName: "kjv")
        
        XCTAssert(mod != nil)
        XCTAssert(mod?.name() == "KJV")
    }

    func testReloadWithKeyString() {
        var mod = mgr?.module(withName: "kjv")
        
        let te = mod?.renderedTextEntries(forRef: "Gen 1")
        XCTAssert((te?.count)! > 0)
        NSLog(te![0] as! String)
        
//        mod?.setKeyString("Gen 1")
//        let text = mod?.renderedText()
//        XCTAssert(text != nil)
//        XCTAssert(text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
//        NSLog(text!)
        
        mgr?.reload()
        mod = mgr?.module(withName: "kjv")
        
        XCTAssert(mod != nil)
        XCTAssert(mod?.name() == "KJV")
    }
}
