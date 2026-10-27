"""Regenerate the screenshot catalog and contact sheets: python3 tool/generate_docs.py.
Requires Pillow. Run from any directory after the Android integration test.
"""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SCREENS = json.loads((ROOT / 'docs/design_map.json').read_text())
FONT = ImageFont.truetype(str(ROOT / 'assets/fonts/Roboto-Regular.ttf'), 15)
BOLD = ImageFont.truetype(str(ROOT / 'assets/fonts/Roboto-Bold.ttf'), 22)


def white_image(path):
    image = Image.open(path).convert('RGBA')
    background = Image.new('RGBA', image.size, 'white')
    background.alpha_composite(image)
    return background.convert('RGB')


def group(number):
    if number <= 13 or number == 44:
        return '认证与引导'
    if number in [19, 20, 23, 24, 25, 26, 27, 31, 40, 41]:
        return '订单与配送'
    if number in [28, 29, 30, 32, 33, 34, 45, 50, 54, 55, 57]:
        return '账户与设置'
    return '餐厅与菜品'


def contact_sheet(numbers, path, columns=5, thumbnail_width=175):
    cell_width, cell_height = thumbnail_width + 20, 426
    rows = (len(numbers) + columns - 1) // columns
    sheet = Image.new('RGB', (columns * cell_width, rows * cell_height + 55), '#f1f1f3')
    draw = ImageDraw.Draw(sheet)
    draw.text((16, 14), 'GUSTO / Flutter App', font=BOLD, fill='#161616')
    for index, number in enumerate(numbers):
        metadata = SCREENS[number - 1]
        image = white_image(ROOT / f'docs/screenshots/{number:02}.png')
        image.thumbnail((thumbnail_width, 380))
        x, y = index % columns * cell_width + 10, index // columns * cell_height + 55
        sheet.paste(image, (x, y))
        title = f'{number:02} {metadata["name"]}'
        while draw.textlength(title, font=FONT) > thumbnail_width:
            title = title[:-2]
        draw.text((x, y + 386), title, font=FONT, fill='#333333')
    sheet.save(path, quality=88, optimize=True)


for batch in range(3):
    numbers = list(range(batch * 20 + 1, batch * 20 + 21))
    contact_sheet(numbers, ROOT / f'docs/screenshots/overview-{batch + 1}.jpg')
contact_sheet([15, 18, 22, 19, 40, 31], ROOT / 'docs/screenshots/overview.jpg', columns=3, thumbnail_width=220)

lines = [
    '# 60 个界面与 Pixso 映射', '',
    '来源页面：`iPhone 11 Pro`（`0:1`）。每个编号都有独立可访问的 App 路由和截图；相似界面使用同一业务组件的不同状态。', '',
    'App 入口：**More → 网格图标 → Pixso Screens**。也可运行 `flutter run --dart-define=SCREEN=编号`。', '',
    'App 截图由 Android 模拟器集成测试生成；原稿图来自 Pixso 导出。键盘由系统在输入框获得焦点时显示，截图保留未弹出键盘时的 App 首屏。', '',
]
for batch in range(3):
    lines += [f'## {batch * 20 + 1:02}–{batch * 20 + 20:02}', '',
              f'![界面概览 {batch + 1}](screenshots/overview-{batch + 1}.jpg)', '',
              '| 编号 | 原始界面 | 模块 | Pixso 节点 | App 截图 | 原稿 |',
              '| --- | --- | --- | --- | --- | --- |']
    for screen in SCREENS[batch * 20:batch * 20 + 20]:
        n = screen['number']
        lines.append(f'| {n:02} | {screen["name"]} | {group(n)} | `{screen["node"]}` | [打开](screenshots/{n:02}.png) | [对照](design/{n:02}.png) |')
    lines.append('')
lines += ['## UI Kit 分类', '',
          '第二个 Pixso 页面为 `UI Kit`（`27:4`），用于提取组件与视觉规范，不作为独立业务界面。', '',
          '| 分类 | Pixso 节点 | 使用位置 |', '| --- | --- | --- |',
          '| Colors Collections | `27:1386` | 黄色、橙色、紫色、灰色与辅助色 |',
          '| Typography | `27:1175` | 标题、正文、辅助文字 |',
          '| Icon Pack | `27:650` | 分类图标、导航和操作图标 |',
          '| Buttons / Actions | `27:311` / `27:375` | 主要、描边与黑色按钮 |',
          '| Input | `27:458` | 表单输入与错误提示 |',
          '| Controls & Tabs | `27:510` | 选项、开关、页签 |',
          '| Navigation Bars | `27:5` | 页面标题和返回导航 |',
          '| Tab Bars & Toolbars | `27:1228` | 五个底部导航入口 |',
          '| Status Bars | `27:557` | 使用系统状态栏与安全区 |',
          '| ArrowLeft / Back | `27:1511` / `27:1509` | 返回操作 |', '']
(ROOT / 'docs/SCREENS.md').write_text('\n'.join(lines))
print('Generated 60-screen catalog and 4 overview images.')
