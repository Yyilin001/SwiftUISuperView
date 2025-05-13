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

## 使用示例 Usage

```swift
import SwiftUI
enum HeaderType: Int, CaseIterable, Identifiable {
    case first = 0
    case second = 1
    case third = 2

    var title: String {
        switch self {
        case .first: "第一个"
        case .second: "第二个"
        case .third: "第三个"
        }
    }

    var id: Int { rawValue }
}
struct ContentView: View {
    @State var selectedType: HeaderType = .first
    var body: some View {
        SuperStickyTabContainer(
            selectedType: $selectedType,
            topMaskView: {
                Color.blue
            }
            ,
            topView: {
                HStack {
                    Spacer()
                    Text("顶部视图")
                    Spacer()
                }
                .frame(height: 200)
                .background(.gray)
            },
            topContent: {
                VStack(spacing: .zero) {
                    Color.white.opacity(0.001)
                        .frame(height: 180).hidden()
                    LazyVStack(spacing: .zero) {
                        ForEach(0 ... 10, id: \.self) { i in
                            Text("第 \(i) 个视图")
                                .padding()
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
                        Text("\(type.id)")
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
                                Text("第 \(i) 个视图")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(i % 2 == 0 ? Color.gray.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    case .second:
                        LazyVStack {
                            ForEach(0 ... 500, id: \.self) { i in
                                Text("第 \(i) 个视图")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(i % 2 == 0 ? Color.gray.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    case .third:
                        LazyVStack {
                            ForEach(0 ... 1000, id: \.self) { i in
                                Text("第 \(i) 个视图")
                                    .padding()
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
                        .frame(width: UIScreen.main.bounds.width + max(0, dropDownOffset * 1.4))
                        .offset(y: min(0, dropDownOffset))
                    Spacer()
                }
            }
        )
        .adsorptionEdges(.all)
        .autoShowTopMask(true)
        .showsIndicators(false)
        .autoHandleTopArea(false)
    }
}

#Preview {
    ContentView()
}

```
