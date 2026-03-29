//
//  StickerMotion.swift
//  Sticker
//
//  Created by Benjamin Pisano on 04/11/2024.
//

import Foundation

public struct StickerMotion: Hashable, Equatable, Sendable {
    public var isActive: Bool = false
    public var lightIntensity: Float = 0
    public var transform: StickerTransform = .neutral
}
