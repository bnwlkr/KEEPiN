//
//  LeaderboardRow.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import SwiftUI


struct LeaderboardRow: View {
	var player: Player
	
    var body: some View {
        HStack {
			Spacer()
			Text(player.username)
			Spacer()
			Text(String(player.highscore))
			Spacer()
		}
    }
}

struct LeaderboardRow_Previews: PreviewProvider {
    static var previews: some View {
		LeaderboardRow(player: Player(username: "Ben", highscore: 20))
    }
}
