//
//  EmojiArtDocument.swift
//  EmojiArt2
//
//  Created by gauri on 05/12/20.
//

import Foundation
import SwiftUI

class EmojiArtDocument: ObservableObject {
    static let pallete = "⭐️🍎🍎🍎📲📲💻"
    @Published
    private var emojiView = EmojiArt() {
        didSet{
            print("json \(emojiView.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiView.json, forKey: "emojiArt")
        }
        willSet{
            objectWillChange.send()
        }
    }
    @Published private (set) var backgroundImge: UIImage?
    init() {
        emojiView = EmojiArt(json: UserDefaults.standard.data(forKey: "emojiArt")) ?? EmojiArt()
        fetchBackGroundImage()
    }
    var emojis : [EmojiArt.Emoji] {emojiView.emojis }
    func addEmoji(_ emoji: String , at location: CGPoint, size : CGFloat)  {
        emojiView.addEmojis(text:emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize)  {
        if let index = emojiView.emojis.firstIndex(matching: emoji) {
            emojiView.emojis[index].x += Int(offset.width)
            emojiView.emojis[index].y += Int(offset.height)
        }
    }
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat)  {
        if let index = emojiView.emojis.firstIndex(matching: emoji){
            emojiView.emojis[index].size = Int((CGFloat(emojiView.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    func setBackGroundUrl(url: URL?)  {
        emojiView.backgroundUrl = url?.imageURL
        fetchBackGroundImage()
    }
    func fetchBackGroundImage()  {
        backgroundImge = nil
        if let url = emojiView.backgroundUrl {
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf: url) {
                    print("downloading content")
                    DispatchQueue.main.async {
                        if url == self.emojiView.backgroundUrl {
                            self.backgroundImge = UIImage(data: data)
                        }
                        
                    }
                    
                }
            }
        }
    }
}
extension EmojiArt.Emoji {
    var fontsize: CGFloat {CGFloat(self.size)}
    var location: CGPoint {CGPoint(x: self.x, y: self.y)}
}
