# SwiftUISuperView

✨ 一个基于 SwiftUI 的高级组件库。

---

## 安装 Installation

### 使用 Swift Package Manager

在 Xcode 中：

1. 点击菜单栏 `File > Add Packages...`
2. 输入项目地址：https://github.com/Yyilin001/SwiftUISuperView.git
3. 选择最新版本并添加到你的项目中

---

SuperStickyTabContainer是推出的第一个视图组件
1. 支持创建具有顶部视图、顶部内容、可吸附切换标签栏、底部内容等复杂布局的场景
2. 自动处理安全区问题
3. 自动记录记录滚动位置

## 🎬 演示视频

[下载视频](https://github.com/Yyilin001/SwiftUISuperView/Resources/SuperStickyTabContainerVideo.mp4)

## 使用示例 Usage


```swift
import SwiftUI
enum HeaderType: Int, CaseIterable, Identifiable {
    case first = 0
    case second = 1
    case third = 2

    var title: String {
        switch self {
        case .first: "第一页"
        case .second: "第二页"
        case .third: "第三页"
        }
    }

    var id: Int { rawValue }
}

struct ContentView: View {
    @State var selectedType: HeaderType = .first
    var body: some View {
        SuperStickyTabContainer(
            selectedType: $selectedType,
            topContent: {
                VStack(spacing: .zero) {
                    Color.white.opacity(0.001)
                        .frame(height: 240).hidden()
                    LazyVStack(spacing: .zero) {
                        ForEach(0 ... 10, id: \.self) { i in
                            HStack {
                                Image("666")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120)
                                Text("第 \(i) 个视图")
                                    .padding()
                            }

                            .frame(maxWidth: .infinity)
                            .background(i % 2 == 0 ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        }.background(.white)
                    }.background(.white)
                }
            },
            adsorptionHeader: { actions in
                HStack(spacing: 12) {
                    ForEach(Array(HeaderType.allCases)) { type in
                        Text(type.title)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedType == type ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedType == type ? .white : .black)
                            .cornerRadius(10)
                            .onTapGesture {
                                actions[type]?()
                            }
                    }
                    Spacer()
                }
                .padding()
                .background(.white)
            },
            bottomContent: {
                VStack(spacing: .zero) {
                    switch selectedType {
                    case .first:
                        LazyVStack {
                            ForEach(0 ... 5, id: \.self) { i in
                                HStack {
                                    Image("1233")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120)
                                    Text("第 \(i) 个视图")
                                        .padding()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(i % 2 == 0 ? Color.gray.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                        }
                    case .second:

                        LazyVStack {
                            ForEach(0 ... 500, id: \.self) { i in
                                HStack {
                                    Image("IMG_3044")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120)
                                    Text("第 \(i) 个视图")
                                        .padding()
                                }
                                .frame(maxWidth: .infinity)
                                .background(i % 2 == 0 ? Color.gray.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                        }
                    case .third:
                        LazyVStack {
                            ForEach(0 ... 1000, id: \.self) { i in
                                HStack {
                                    Image("IMG_3045")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120)
                                    Text("第 \(i) 个视图")
                                        .padding()
                                }
                                .frame(maxWidth: .infinity)
                                .background(i % 2 == 0 ? Color.gray.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                        }
                    }
                }.background(.red)
            },
            scroBackground: { dropDownOffset in
                VStack {
                    Image("bg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width + 200 + max(0, dropDownOffset * 1.4))
                        .offset(y: min(0, dropDownOffset))
                    Spacer()
                }
            }
        )
        .adsorptionEdges(.all)
        .autoShowTopMask(true)
        .showsIndicators(false)
        .autoHandleTopArea(true)
    }
}

```
