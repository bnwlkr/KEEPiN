//
//  LeaderboardView.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import SwiftUI

struct LeaderboardView: View {
	@ObservedObject var leaderboardManager = LeaderboardManager()
	var dismiss: () -> Void = {}
	var gameVC: GameViewController?
	init(gameVC: GameViewController, dismiss: @escaping () -> Void) {
		self.dismiss = dismiss
		self.gameVC = gameVC
		UserDefaults.standard.set(true, forKey: "seenLeaderboard")
	}

	var body: some View {
		
		NavigationView {
			List (leaderboardManager.players.enumerated().map({$0}), id: \.element.username) { i, player in
				LeaderboardRow(player: player, isTop: i == 0)
			}
			.navigationBarTitle("LEADERBOARD")
			.navigationBarItems(trailing:
				Button (action: dismiss) {
					Text("Done").fontWeight(.bold)
				}
			)
		}.onAppear {
			self.leaderboardManager.getLeaderboard()
			if KeyChain.username == nil {
				self.gameVC?.requestUsername(leaderboardManager: self.leaderboardManager)
			} else {
				LeaderboardManager.newHighscore(username: KeyChain.username!, highscore: KeyChain.highscore, success: nil)
			}
		}
    }
}


struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Whatever, dude")
    }
}
