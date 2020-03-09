//
//  LeaderboardManager.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import Foundation
import Alamofire

let secret = "N9CXZIY331zHMGdtQQcS9wkV5aaqBfWJ357aArEpVzE="

class LeaderboardManager: ObservableObject {
	@Published var players: [Player] = []
	static var apiUrl = "https://keepin.bnwl.kr/"
	
	func getLeaderboard() {
		let parameters: Parameters = ["secret": secret]
		AF.request(LeaderboardManager.apiUrl + "leaderboard", method: .post, parameters: parameters).responseJSON { response in
			switch response.result {
				case .failure(let error):
					print(error)
				case .success(let afResult):
					if let result = afResult as? [[String:Any]] {
						var players: [Player] = []
						for playerData in result {
							if let username = playerData["username"] as? String {
								if let highscore = playerData["highscore"] as? Int {
									if let region = playerData["region"] as? String {
										players.append(Player(username: username, highscore: highscore, region: region))
									}
								}
							}
						}
						self.players = players.sorted(by: {playerA, playerB  in playerA.highscore > playerB.highscore})
					}
			}
		}
	}
	
	
	static func existsUser(username: String, completion: @escaping (Bool) -> ()) {
		let parameters: Parameters = ["username": username, "secret": secret]
		AF.request(apiUrl + "existsuser", method: .post, parameters: parameters).responseString { response in
			switch response.result {
				case .success(let result):
					completion(result == "true")
				case .failure(let error):
					print(error)
			
			}
		}
	}
	
	static func newHighscore(username: String, highscore: Int, success: (()->())?) {
		var parameters: Parameters = ["username": username, "highscore": highscore, "secret": secret]
		if let region = Locale.current.regionCode {
			parameters["region"] = region
		}
		AF.request(apiUrl + "highscore", method: .post, parameters: parameters).response { response in
			switch response.result {
				case .failure(let error):
					print(error)
				case .success:
					success?()
			}
		}
	}
	
}
