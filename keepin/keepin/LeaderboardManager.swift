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
	static var apiUrl = "https://keepin.bnwl.kr/"
	
	func getLeaderboard() {
		AF.request(LeaderboardManager.apiUrl + "leaderboard").responseJSON { response in
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
	
	
	static func existsUser(username: String, completion: @escaping (Bool) -> ()) {
		let parameters: Parameters = ["username": username]
		AF.request(apiUrl + "existsuser", method: .post, parameters: parameters).responseString { response in
			switch response.result {
				case .success(let result):
					completion(result == "true")
				case .failure(let error):
					print(error)
			
			}
		}
	}
	
	static func newUser (username: String, highscore: Int, success: @escaping ()->(), failure: @escaping ()->()) {
		let parameters: Parameters = ["username": username, "highscore": highscore]
		AF.request(apiUrl + "newuser", method: .post, parameters: parameters).response { response in
			switch response.result {
				case .failure(let error):
					print(error)
				case .success(let result):
					print(result!)
			}
		}
		
	}


}
