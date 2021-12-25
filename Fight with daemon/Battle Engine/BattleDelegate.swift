//
//  BattleDelegate.swift
//  Fight with daemon
//
//  Created by Mohammad Bitar on 12/25/21.
//

import Foundation

public protocol BattleDelegate {
    
    func fight(for activity: Activity, continueCompletion: @escaping (Result) -> Void, buyWeaponsCompletion: @escaping () -> Void)

    func didCompleteBattle(withResults results: [Result])
    
    func buyWeapons(amount: Int)
}
