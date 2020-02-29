//
//  LeaderboardManager.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import Foundation
import Alamofire


class LeaderboardManager {
		
	static var apiUrl = "https://keepin.bnwl.kr/"
	
	static func getLeaderboard() {
		AF.request(LeaderboardManager.apiUrl + "leaderboard").responseJSON { response in
			print(response)
		}
	}


}
