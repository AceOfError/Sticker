//
//  StickerShaderUpdater.swift
//  FoilTest
//
//  Created by Benjamin Pisano on 03/11/2024.
//

import SwiftUI
import Observation

@Observable
final class StickerShaderUpdater {
    typealias ChangeHandler = (_ motion: StickerMotion) -> Void

    private(set) var motion: StickerMotion = .init()
    
    private let onChange: ChangeHandler

    init(onChange: @escaping @Sendable ChangeHandler) {
        self.onChange = onChange
    }

    @MainActor
    func update(with transform: StickerTransform, lightIntensity: Float = 1) {
        motion = .init(
            isActive: true,
            lightIntensity: lightIntensity,
            transform: transform
        )
        onChange(motion)
    }

    @MainActor
    func setNeutral() {
        motion = .init(
            isActive: false,
            lightIntensity: 0,
            transform: .neutral
        )
        onChange(motion)
    }
}

extension StickerShaderUpdater: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(motion)
    }
}

extension StickerShaderUpdater: Equatable {
    static func == (lhs: StickerShaderUpdater, rhs: StickerShaderUpdater) -> Bool {
        lhs.motion == rhs.motion
    }
}

extension View {
    func onStickerShaderChange(_ onChange: @escaping @Sendable StickerShaderUpdater.ChangeHandler) -> some View {
        environment(\.stickerShaderUpdater, .init(onChange: onChange))
    }
}

extension EnvironmentValues {
    @Entry var stickerShaderUpdater: StickerShaderUpdater = .init(onChange: { _ in })
}
