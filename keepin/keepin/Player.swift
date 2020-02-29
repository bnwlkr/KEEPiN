//
//  Player.swift
//  KEEPiN
//
//  Created by Ben Walker on 2020-02-29.
//  Copyright © 2020 Ben Walker. All rights reserved.
//

import Foundation


class Player {
	var username: String!
	var highscore: Int = 0
	
	init(username: String, highscore: Int) {
    	self.username = username
    	self.highscore = highscore
	}
}
