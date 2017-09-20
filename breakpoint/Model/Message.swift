//
//  Message.swift
//  breakpoint
//
//  Created by Max Furman on 9/10/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import Foundation


class Message{
    private var _content: String
    private var _senderId: String

    
    var content: String {
        return _content
    }
    
    var senderId: String{
        return _senderId
    }
    

    init(senderId: String, content: String) {
        self._content = content
        self._senderId = senderId
    }
}
