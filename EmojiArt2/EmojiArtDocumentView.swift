//
//  EmojiArtDocumentView.swift
//  EmojiArt2
//
//  Created by gauri on 04/12/20.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    var body: some View {
        VStack{
            ScrollView(.horizontal){
                HStack {
                    ForEach(EmojiArtDocument.pallete.map{ String($0 )}, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: defaultEmojiSize))
                            .onDrag{NSItemProvider(object: emoji as NSString)}
                    }
                }
            }
            .padding(.horizontal)
            GeometryReader{ geometry in
                ZStack {
                    Rectangle().foregroundColor(.yellow).overlay(
                        OptionalImage(uiImage: document.backgroundImge)
                            .scaleEffect(zoomScale)
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    .clipped()
                    .gesture(zoomGesture())
                    .edgesIgnoringSafeArea([.bottom ,.horizontal])
                    .onDrop(of: ["public.image","public.text"], isTargeted: nil) { providers ,location in
                        var location = geometry.convert(location, from: .global)
                        location = CGPoint(x: location.x - geometry.size.width/2 , y: location.y - geometry.size.height/2)
                        location = CGPoint(x: location.x / zoomScale ,y: location.y / zoomScale)
                        return drop(providers: providers, location: location)
                    }
                }
                ForEach(document.emojis){ emoji in
                    Text(emoji.text)
                        .font(font(for: emoji))
                        .position(position(for: emoji, size: geometry.size))
                }
                
            }
        }
    }
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2).onEnded{
            withAnimation {
                zoomTofit(document.backgroundImge, in: size )
            }
            
        }
    }
    private func zoomTofit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0 , image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            print("hzoom \(hZoom)")
            print("vzoom \(vZoom)")
            self.steadyStateZoomScale = min(hZoom, vZoom)
            print("zoom scale \(zoomScale)")
        }
    }
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    private func zoomGesture() -> some Gesture{
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
            }
    }
    //Pan offset
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
        }
        .onEnded { finalDragGestureValue in
            self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
        }
    }
    
    private func font(for emoji: EmojiArt.Emoji) -> Font{
        Font.system(size: emoji.fontsize)
    }
    private func position(for emoji: EmojiArt.Emoji, size: CGSize ) -> CGPoint {
        var  location = emoji.location
        location = CGPoint(x: location.x * zoomScale ,y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y:location .y + size.height/2)
        return location
    }
    private func drop(providers: [NSItemProvider], location: CGPoint) -> Bool{
        let  imagefound = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped url \(url)")
            document.setBackGroundUrl(url: url)
        }
        if !imagefound {
            let emojifound = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
            return emojifound
        }
        return imagefound
    }
    private let defaultEmojiSize : CGFloat = 40
    
}
struct OptionalImage: View {
    var uiImage: UIImage?
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
