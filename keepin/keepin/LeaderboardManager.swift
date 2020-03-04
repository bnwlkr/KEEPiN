//
//  LeaderboardManager.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import Foundation
import Alamofire


class LeaderboardManager: ObservableObject {
	@Published var players: [Player] = []
	var apiUrl = "https://keepin.bnwl.kr/"
	
	func getLeaderboard() {
		AF.request(apiUrl + "leaderboard").responseJSON { response in
			switch response.result {
				case .failure(let error):
					print(error)
				case .success(let afResult):
					if let result = afResult as? [[String:Any]] {
						var players: [Player] = []
						for playerData in result {
							if let username = playerData["username"] as? String {
								if let highscore = playerData["highscore"] as? Int {
									players.append(Player(username: username, highscore: highscore))
								}
							}
						}
						self.players = players
					}
			}
		}
	}
	
	func createUser (username: String, success: @escaping ()->(), failure: @escaping ()->()) {
		
		
	}


}
