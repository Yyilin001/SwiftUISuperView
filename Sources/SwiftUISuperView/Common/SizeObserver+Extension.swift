//
//  SwiftUIView.swift
//  SwiftUISuperView
//
//  Created by 徐徐年年 on 2025/5/13.
//

import SwiftUI

///获取视图大小
public struct SizeObserver: ViewModifier {
    let onChange: (CGSize) -> Void
    public func body(content: Content) -> some View {
        content
            .background(alignment: .center, content: {
                GeometryReader { geometry in
                    Color.clear
                        .onAppear { onChange(geometry.size) }
                        .onChange(of: geometry.size) { size in
                            onChange(size)
                        }
                }}
            )
    }
}

extension View {
    ///获取视图大小
    public func observeSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
        modifier(SizeObserver(onChange: onChange))
    }
}
