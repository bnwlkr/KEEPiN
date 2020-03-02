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
	init(dismiss: @escaping () -> Void) {
		leaderboardManager.getLeaderboard()
		self.dismiss = dismiss
	}

	var body: some View {
		NavigationView {
			List(leaderboardManager.players) { player in
				HStack {
					Text(player.username)
					Text(String(player.highscore))
				}
			}
			.navigationBarTitle("LEADERBOARD 🏆")
			.navigationBarItems(trailing:
				Button (action: dismiss) {
					Text("Done").fontWeight(.bold)
				}
			)
		}
    }
}


struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView(dismiss: {})
    }
}
