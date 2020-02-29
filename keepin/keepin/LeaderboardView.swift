//
//  LeaderboardView.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import SwiftUI

struct LeaderboardView: View {
	var players: Array<Player>
	init() {
		LeaderboardManager.getLeaderboard()
		self.players = []
	}


	var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
