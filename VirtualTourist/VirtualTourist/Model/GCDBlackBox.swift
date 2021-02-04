//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Neri Quiroz on 12/16/20.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
