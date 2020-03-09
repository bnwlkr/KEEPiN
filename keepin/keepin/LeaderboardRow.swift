//
//  LeaderboardRow.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import SwiftUI
import Foundation


struct LeaderboardRow: View {
	var player: Player
	var isTop: Bool
	
    var body: some View {
        HStack {
			Text(player.username).padding(.leading)
			Text(flag(region: player.region) + (isTop ? " 👑" : "")).font(.system(size: 20))
			Spacer()
			Text(String(player.highscore)).padding(.trailing)
		}.font(.system(size: 24))
    }
    
    func flag(region: String) -> String {
		if region == "" { return "" }
		let base : UInt32 = 127397
		var s = ""
		for v in region.unicodeScalars {
			s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
		}
		return String(s)
	}
    
}

struct LeaderboardRow_Previews: PreviewProvider {
    static var previews: some View {
		LeaderboardRow(player: Player(username: "Ben", highscore: 20, region: "CA"), isTop: true)
    }
}
