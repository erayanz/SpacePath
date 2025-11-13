//
// SpacePathApp.swift
// SpacePath
//
// Created by Rayan Alzahrani on 11/05/1447 AH.
//

import SwiftUI

@main
struct SpacePathApp: App {
    init(){
        Thread.sleep(forTimeInterval: 0.50)
    }
    var body: some Scene {
        WindowGroup {
            SpacePathMainView()  // CHANGED THIS
        }
    }
}
