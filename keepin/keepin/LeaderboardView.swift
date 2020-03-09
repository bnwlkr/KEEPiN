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
		leaderboardManager.getLeaderboard()
		self.dismiss = dismiss
		self.gameVC = gameVC
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
			if UserDefaults.standard.string(forKey: "username") == nil {
				self.gameVC?.requestUsername(leaderboardManager: self.leaderboardManager)
			}
		}
    }
}


struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Whatever, dude")
    }
}
