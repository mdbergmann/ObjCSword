//
//  SwordFilterTest.swift
//  ObjCSword
//
//  Created by Manfred Bergmann on 14.04.17.
//
//

import XCTest

class SwordFilterTest: XCTestCase {
    
    var mgr: SwordManager?
    
    override func setUp() {
        super.setUp()
        
        let modulesDir = Bundle(for:type(of: self)).resourcePath!.appendingFormat("/TestModules")
        NSLog("modulesDir: \(modulesDir)")
        
        Configuration.config(withImpl: OSXConfiguration())
        FilterProviderFactory.factory().initWithImpl(DefaultFilterProvider())
        mgr = SwordManager(path:modulesDir)
    }
    
    func testRenderedOsisFootnote() {
        mgr?.setGlobalOption(SW_OPTION_FOOTNOTES, value:SW_ON)
        
        var bibleMod = mgr?.module(withName: "KJV") as! SwordBible
        var renderedText = bibleMod.renderedTextEntry(forRef:"gen 1:6")
        NSLog("%@:%@", renderedText!.key, renderedText!.text)
        XCTAssertTrue(renderedText!.text.contains("<a href=\"passagestudy.jsp?"))
        
        bibleMod = mgr?.module(withName: "KJV") as! SwordBible
        renderedText = bibleMod.renderedTextEntry(forRef:"gen 1:6")
        NSLog("%@:%@", renderedText!.key, renderedText!.text)
        XCTAssertTrue(renderedText!.text.contains("<a href=\"passagestudy.jsp?"))

        bibleMod = mgr?.module(withName: "KJV") as! SwordBible
        renderedText = bibleMod.renderedTextEntry(forRef:"gen 1:6")
        NSLog("%@:%@", renderedText!.key, renderedText!.text)
        XCTAssertTrue(renderedText!.text.contains("<a href=\"passagestudy.jsp?"))

        mgr?.setGlobalOption(SW_OPTION_FOOTNOTES, value:SW_OFF)
    }
}
