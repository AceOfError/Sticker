//
//  File.swift
//  Sticker
//
//  Created by Benjamin Pisano on 13/11/2024.
//

import SwiftUI

public struct DragStickerMotionEffect: StickerMotionEffect {
    let intensity: Double

    @State private var transform: StickerTransform = .neutral
    @State private var settleTimer: Timer?

    @Environment(\.stickerShaderUpdater) private var shaderUpdater

    public func body(content: Content) -> some View {
        content
            .withViewSize { view, size in
                let xRotation: Double = (transform.x / size.width) * intensity
                let yRotation: Double = (transform.y / size.height) * intensity
                view
                    .rotation3DEffect(.radians(xRotation), axis: (0, 1, 0))
                    .rotation3DEffect(.radians(yRotation), axis: (-1, 0, 0))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                settleTimer?.invalidate()
                                settleTimer = nil
                                transform = .init(
                                    x: gesture.location.x - size.width / 2,
                                    y: gesture.location.y - size.height / 2
                                )
                                shaderUpdater.update(with: transform)
                            }
                            .onEnded { _ in
                                let startX = transform.x
                                let startY = transform.y
                                let startTime = CACurrentMediaTime()
                                let duration = 0.4

                                settleTimer?.invalidate()
                                let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { timer in
                                    let elapsed = CACurrentMediaTime() - startTime
                                    let t = min(elapsed / duration, 1.0)
                                    // Smooth ease-out curve
                                    let ease = 1 - pow(1 - t, 3)

                                    let x = startX * (1 - ease)
                                    let y = startY * (1 - ease)
                                    let light = Float(1 - ease)

                                    transform = .init(x: x, y: y)

                                    if t >= 1.0 {
                                        transform = .neutral
                                        shaderUpdater.setNeutral()
                                        timer.invalidate()
                                        settleTimer = nil
                                    } else {
                                        shaderUpdater.update(with: .init(x: x, y: y), lightIntensity: light)
                                    }
                                }
                                RunLoop.main.add(timer, forMode: .common)
                                settleTimer = timer
                            }
                    )
            }
    }
}

public extension StickerMotionEffect where Self == DragStickerMotionEffect {
    static var dragGesture: Self {
        .dragGesture()
    }

    static func dragGesture(intensity: Double = 1) -> Self {
        .init(intensity: intensity)
    }
}
