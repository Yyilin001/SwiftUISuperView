// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
/// 一个支持顶部吸附切换的通用容器视图组件。
///
/// 该视图支持创建具有顶部视图、顶部内容、可吸附切换标签栏、底部内容等复杂布局的场景。
/// 支持在滚动时吸附顶部标签栏，并提供可切换内容页的功能同时自动记录滚动位置。
///
/// - Parameters:
///   - selectedType: 当前选中的标签类型（必须是 `CaseIterable` + `Identifiable` +`Hashable`）
///   - topMaskView: 顶部吸附遮罩，用于在头部吸附的时候覆盖安全区，默认是白色背景
///   - topView: 不可滚动的顶部视图（可选）
///   - topContent: 可滚动的吸附头部上部内容区域（可滚动）
///   - adsorptionHeader: 吸附头部构建器（接收切换事件的回调字典）
///   - bottomContent: 吸附头部下部主要内容（可滚动）
///   - background: 整体背景（可选）
///   - scroBackground: ScrollView 背景（可选）
public struct SuperStickyTabContainer<HeaderSwitch: CaseIterable & Identifiable & Hashable, TopMask: View, Top: View, TopContent: View, Header: View, BottomContent: View, Background: View, ScroBackground: View>: View {
    private let spaceName: String = UUID().uuidString
    private let suggestionHeight = 10.0
    private var edges: Edge.Set = []
    private var autoShowTopMask = true
    private var showsIndicators = true
    private var autoHandleTopArea = true
    private var onOffsetChange: (CGFloat) -> Void = { _ in }
    private let topMaskView: TopMask
    private let topView: Top
    private let topContent: TopContent
    private let adsorptionHeaderBuilder: (_ actions: [HeaderSwitch: () -> Void]) -> Header
    private let bottomContent: BottomContent
    private let background: Background
    private let scroBackground: (_ dropDownOffset: CGFloat) -> ScroBackground

    public init(
        selectedType: Binding<HeaderSwitch>,
        @ViewBuilder topMaskView: () -> TopMask = { Color.white },
        @ViewBuilder topView: () -> Top = { EmptyView() },
        @ViewBuilder topContent: () -> TopContent = { EmptyView() },
        @ViewBuilder adsorptionHeader: @escaping (_ actions: [HeaderSwitch: () -> Void]) -> Header,
        @ViewBuilder bottomContent: () -> BottomContent = { EmptyView() },
        @ViewBuilder background: () -> Background = { EmptyView() },
        @ViewBuilder scroBackground: @escaping (_ dropDownOffset: CGFloat) -> ScroBackground = { _ in EmptyView() }
    ) {
        self.topMaskView = topMaskView()
        self.topView = topView()
        self.topContent = topContent()
        adsorptionHeaderBuilder = adsorptionHeader
        self.bottomContent = bottomContent()
        self.background = background()
        self.scroBackground = scroBackground
        _selectedType = selectedType
    }

    @State private var topHeaderOffset: CGFloat = .zero
    @State private var showTopMask = false
    @State private var offsetY: CGFloat = 0
    @State private var offsets: [HeaderSwitch: CGFloat] = [:]
    @State private var topContentHeight: CGFloat = .zero
    @State private var topViewHeight: CGFloat = .zero
    @State private var headerHeight: CGFloat = .zero
    @State private var dropDownOffset: CGFloat = .zero
    @Binding var selectedType: HeaderSwitch
    public var body: some View {
        ZStack {
            background.ignoresSafeArea(edges: edges)
            GeometryReader { proxyFrame in
                VStack(spacing: .zero) {
                    topView.observeSize { topViewHeight = $0.height }
                        .zIndex(1)
                    Rectangle().frame(height: 0)
                        .overlay(alignment: .bottom) {
                            GeometryReader { proxy -> Color in
                                let minY = proxy.frame(in: .named(spaceName)).minY
                                Task { @MainActor in
                                    topHeaderOffset = minY
                                }
                                return Color.clear
                            }
                            .frame(width: 0, height: 0)
                        }
                    ScrollViewReader { scro in
                        ScrollView(.vertical, showsIndicators: showsIndicators) {
                                VStack(spacing: .zero) {
                                    topContent.observeSize { topContentHeight = $0.height }
                                    GeometryReader { proxy in
                                        let minY = proxy.frame(in: .named(spaceName)).minY

                                        let offset = autoHandleTopArea && edges.contains(.top) && topViewHeight < proxyFrame.safeAreaInsets.top ? minY - topHeaderOffset - proxyFrame.safeAreaInsets.top + topViewHeight : minY - topHeaderOffset
                                        let isOffset = offset <= 0
                                        if isOffset {
                                            Task { @MainActor in
                                                showTopMask = true
                                                if dropDownOffset != offset - topContentHeight {
                                                    dropDownOffset = offset - topContentHeight
                                                    onOffsetChange(dropDownOffset)
                                                }
                                               
                                            }
                                        } else {
                                            Task { @MainActor in
                                                showTopMask = false
                                                if dropDownOffset != offset - topContentHeight {
                                                    dropDownOffset = offset - topContentHeight
                                                    onOffsetChange(dropDownOffset)
                                                }
                                            }
                                        }

                                        let actions: [HeaderSwitch: () -> Void] = Dictionary(uniqueKeysWithValues: HeaderSwitch.allCases.map { type in
                                            (type, {
                                                offsets[selectedType] = minY
                                                if minY > topViewHeight {
                                                    offsets[type] = minY
                                                } else {
                                                    let offset = edges.contains(.top) && topViewHeight > proxyFrame.safeAreaInsets.top ? topViewHeight - proxyFrame.safeAreaInsets.top - 1  : topViewHeight - 1
                                                    if offsets[type] == .zero {
                                                        if isOffset {
                                                            offsets[type] = offset
                                                        }
                                                    } else {
                                                        offsets[type] = min(offsets[type]!, offset)
                                                    }
                                                }
                                                selectedType = type
                                                Task { @MainActor in
                                                    scro.scrollTo("\(type.id)", anchor: .top)
                                                }
                                            })
                                        })
                                        return adsorptionHeaderBuilder(actions)
                                            .observeSize { headerHeight = $0.height }
                                            .offset(y: isOffset ? -offset : .zero)
                                    }
                                    .zIndex(Double.greatestFiniteMagnitude)
                                    VStack(spacing:.zero){
                                        Color.white.frame(height: max(0, headerHeight - suggestionHeight)).hidden()
                                        bottomContent
                                    }
                                }
                                .overlay {
                                    ForEach(Array(HeaderSwitch.allCases)) { type in
                                        if let offset = offsets[type], type == selectedType {
                                            VStack(spacing: .zero) {
                                                Color.white.opacity(0.001).frame(height: max(0, -offset + topHeaderOffset + topContentHeight))
                                                Color.white.frame(height: 0).id("\(type.id)")
                                                Spacer()
                                            }
                                            .hidden()
                                            .allowsHitTesting(false)
                                        }
                                    }
                                }
                        }
                        .background { scroBackground(dropDownOffset) }
                    }
                }
                .clipped()
                .ignoresSafeArea(edges: edges)
                .coordinateSpace(name: spaceName)
                .overlay(alignment: .top) {
                    if autoShowTopMask && showTopMask {
                        topMaskView.frame(height: proxyFrame.safeAreaInsets.top)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                    }
                }
            }
        }.onAppear {
            offsets = createOffsets()
        }
    }

    private func createOffsets() -> [HeaderSwitch: CGFloat] {
        return HeaderSwitch.allCases.reduce(into: [:]) { result, key in
            result[key] = 0
        }
    }
}

extension SuperStickyTabContainer {
    /// 设置忽略的 SafeArea 边缘。
    /// - Parameter edges: 要忽略的边缘（如 `.top`、`.bottom`）
    /// - Returns: 修改后的 `StickyTabContainer`
    public func adsorptionEdges(_ edges: Edge.Set) -> SuperStickyTabContainer {
        var config = self
        config.edges = edges
        return config
    }

    /// 设置是否自动显示安全区遮罩。
    /// - Parameter show: Bool (`true`、`false`）
    /// - Returns: 修改后的 `StickyTabContainer`
    public func autoShowTopMask(_ show: Bool) -> SuperStickyTabContainer {
        var config = self
        config.autoShowTopMask = show
        return config
    }

    /// 设置是否显示滚动指示器。
    /// - Parameter show: Bool (`true`、`false`）
    /// - Returns: 修改后的 `StickyTabContainer`
    public func showsIndicators(_ show: Bool) -> SuperStickyTabContainer {
        var config = self
        config.showsIndicators = show
        return config
    }

    /// 设置吸附头部视图是否自动处理顶部安全区。
    /// - Parameter auto: Bool (`true`、`false`）
    /// - Returns: 修改后的 `StickyTabContainer`
    public func autoHandleTopArea(_ auto: Bool) -> SuperStickyTabContainer {
        var config = self
        config.autoHandleTopArea = auto
        return config
    }
    
    /// 设置一个回调，用于监听偏移量（offset）的变化。
    /// - Parameter handler: 接收当前偏移量的回调闭包，参数为 `CGFloat`。
    /// - Returns: 修改后的 `SuperStickyTabContainer` 实例。
    public func onOffsetChange(_ handler: @escaping (CGFloat) -> Void) -> SuperStickyTabContainer {
        var copy = self
        copy.onOffsetChange = handler
        return copy
    }
}
