//
//  Player.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import Foundation


class Player: Identifiable {
	
	var username: String!
	var highscore: Int = 0
	var region: String!
	
	init(username: String, highscore: Int, region: String) {
    	self.username = username
    	self.highscore = highscore
    	self.region = region
	}
}
