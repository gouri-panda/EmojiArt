//
//  EmojiArt.swift
//  EmojiArt2
//
//  Created by gauri on 05/12/20.
//

import Foundation
struct EmojiArt: Codable {
    var backgroundUrl: URL?
    var emojis = [Emoji]()
    var uniqueEmojiId = 0
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        var id: Int
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size  = size
            self.id = id
        }
    }
    init?(json: Data?) {
        if json != nil , let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt
        }else {
            return nil
        }
    }
    init(){}
    
    
    mutating func addEmojis(text: String ,x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    static let STORE_PREFERENCE = "emojiart"
    //    private mutating func decodeJson(json: Data?) {
    //        if json != nil {
    //            self = JSONDecoder.decode(EmojiArt())
    //        }
    //    }
}
