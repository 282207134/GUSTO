# 验证记录

验证日期：2026 年 10 月 27 日（Asia/Tokyo）。

## 环境

- macOS ARM64；Flutter 3.41.6 stable，Dart 3.11.4。
- Android 模拟器：`emulator-5554`，Android 15 / API 35，ARM64。
- 模拟器显示分辨率：750 × 1624，DPR 2，逻辑尺寸约 375 × 812。
- Android、iOS、Web 工程均已生成。本次实际运行与截图验证针对 Android；未验证 iOS 运行。

## 检查结果

| 项目 | 结果 | 验证内容 |
| --- | --- | --- |
| `flutter analyze` | 通过，无问题 | 应用、测试和驱动代码的静态分析 |
| `flutter test` | 5 个测试通过 | 金额与数量、持久化订单快照、筛选结果、60 页布局、完整下单与确认收货 |
| Android 集成测试 | 通过 | 遍历 60 页、生成截图、添加菜品、结算下单、发送聊天消息 |
| Android Release APK | 构建通过 | 可安装的演示包，使用工程默认演示签名 |
| Release 安装启动 | 通过 | 已在模拟器安装并启动首页，见 `screenshots/live-home.png` |
| 截图检查 | 已完成 | 60 张 App 图与 60 张原稿图对应；复核主要页面、图片与 Logo |

测试中的页面遍历使用演示购物车和收藏，覆盖空状态、错误状态、弹窗与筛选变体。正常 App 从空购物车启动。下单流程使用 Cash，避免依赖外部支付。

## 自动化测试

```bash
flutter analyze
flutter test
bash tool/capture_screens.sh emulator-5554
flutter build apk --release
```

脚本将 60 页分为三组运行 `flutter drive`，降低截图回传的内存占用，通过截图驱动保存 `docs/screenshots/01.png` 至 `60.png`。这些图片来自模拟器内 Flutter 渲染的 App 画面，不含系统键盘；实际输入时由系统键盘接管。更换模拟器分辨率后重新执行即可生成新尺寸截图。

生成截图目录及概览图：

```bash
# 如本机没有 Pillow：python3 -m pip install Pillow
python3 tool/generate_docs.py
```

## 人工复核

- 首页分类、餐厅图片、菜单图片和品牌 Logo 与 Pixso 素材逐项对应。
- 菜品配料与数量影响单价，购物车与结算使用同一金额来源。
- 支付表单验证数字、有效期和 CVV；只保存卡号末四位。
- 地址增改与默认地址切换、收藏、促销码、设置和消息可在本地使用。
- 已修正测试发现的分类网格高度、半宽按钮与附近餐厅卡片溢出。
- 文档中的图片链接均使用项目相对路径；60 个页面节点与截图已建立索引。

## 实现边界

此版本验证的是 UI 与本地演示流程。短信、身份认证、在线支付、地图服务、推送、外部通话与实时配送没有服务端连接，不代表真实业务服务可用。原稿的历史日期、餐厅数量和部分内容属于样例信息。

三组截图的机器可读验收记录及 APK 校验值见 [capture_report.json](capture_report.json)。
