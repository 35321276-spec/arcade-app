# 怀旧游戏厅 → iPad 真 App（IPA）编译说明

目标：把 8 个离线 HTML 游戏打包成一个真正的 iOS App 图标，装到 iPad mini 3（iOS 12.5.8）上，**不依赖电脑、不联网**。

---

## 现实前提（先看，避免白忙）

1. **签名**：编译出来的是"未签名 IPA"，必须用你的 Apple ID 签名才能装进 iPad。
   - 用爱思助手（电脑已装好）的"免费签名"：App **7 天过期**，过期后连电脑重签一次即可，游戏文件不丢。
   - 这是苹果对免费账号的硬限制，绕不过去。
2. **编译必须在 Mac 上进行**：你的 Windows 电脑没有 Xcode，编译这一步用 GitHub 的免费云端 Mac 完成。
3. **需要一个免费的 GitHub 账号**：注册只要 2 分钟，用于存放工程和触发云编译。

---

## 第一步：注册 GitHub（约 2 分钟）

1. 浏览器打开 https://github.com/signup
2. 填邮箱、密码、用户名（随便起，如 `huaijiuxyz`）
3. 验证邮箱 → 完成

---

## 第二步：新建仓库并上传工程

1. 登录后，点右上角 **"+" → "New repository"**
2. **Repository name** 填：`arcade-app`
3. 选 **Public**（私有仓库也能编译，但 Public 最简单）
4. **不要**勾选 "Add a README"（保持空仓库）
5. 点 **"Create repository"**
6. 在仓库页面找到 **"uploading an existing file"** 链接，点进去
7. 把我给你的 `ios-app.zip` 解压，把解压出来的 **`ios-app` 文件夹里的内容**（注意：是里面的文件，不是 ios-app 这个文件夹本身）**全选拖进上传框**
   - 关键：仓库根目录下应该直接能看到 `project.yml`、`Arcade` 文件夹、`.github` 文件夹
   - `.github` 是隐藏文件夹，拖拽时可能被忽略 —— 如果上传后仓库里看不到它，见下方"补充上传 .github"
8. 页面底部点 **"Commit changes"**

### 补充上传 .github（如果拖拽丢了隐藏文件夹）

GitHub 网页版拖文件夹经常漏掉 `.github` 这个隐藏目录。补传方法：

1. 进入仓库 → 点 **"Add file" → "Create new file"**
2. 文件名框里输入：`.github/workflows/build.yml`（斜杠会自动创建目录）
3. 打开 compressive 给你的工程里 `ios-app/.github/workflows/build.yml`，把内容整段复制粘贴进来
4. 底部点 **"Commit new file"**

---

## 第三步：触发云编译

1. 上传完成后，等几秒，点仓库顶部的 **"Actions"** 标签
2. 左侧应该出现一个叫 **"Build 怀旧游戏厅 IPA"** 的工作流
3. 如果因为 `.github` 是后补的没有自动触发：点它 → 右侧点 **"Run workflow" → "Run workflow"**
4. 开始编译，通常需要 **3～8 分钟**（首次可能更久）
5. 页面中间出现绿色勾 ✅ 就是成功；红色 ❌ 就是失败（点进去看日志，把报错发给我）

---

## 第四步：下载 IPA

1. 编译成功的那次运行页面，往下拉到 **"Artifacts"** 区域
2. 点 **"Arcade-unsigned-ipa"** 下载（是个 zip）
3. 解压得到 `Arcade.ipa`

---

## 第五步：签名并安装到 iPad

1. 电脑上打开**爱思助手**（已装好，v9.22）
2. 数据线连接 iPad，点"信任此电脑"
3. 左侧菜单 → **"应用游戏"** → 顶部 **"导入安装"**（或把 IPA 直接拖进应用列表）
4. 选择刚下载的 `Arcade.ipa`
5. 弹出签名方式时选 **"使用 Apple ID 签名"** → 输入你的 Apple ID 和密码
6. 等待安装完成，iPad 桌面出现 **"怀旧游戏厅"** 图标

### 首次打开要信任证书

iPad 上：**设置 → 通用 → VPN与设备管理（或"描述文件与设备管理"）→ 你的 Apple ID → 信任**

之后点桌面图标就能玩了，8 个游戏全是离线本地的。

---

## 7 天过期怎么办

免费 Apple ID 签名的 App 7 天后打不开。届时：

1. iPad 数据线连电脑
2. 爱思助手 → 应用游戏 → 找到"怀旧游戏厅" → 点"重签名"
3. 输一次 Apple ID 密码，1 分钟搞定，游戏数据不丢

---

## 出问题了怎么办

- **Actions 报错红色**：点进去 → 点失败的那一步 → 把红色错误文字截图发给我
- **找不到 Artifacts**：说明编译没成功，看上一条
- **安装到 iPad 打不开**：检查证书信任那一步（上面第五步末尾）
- **游戏里点返回没反应**：告诉我，我在壳里修悬浮返回按钮

---

## 工程文件说明（供参考）

```
ios-app/
├── .github/workflows/build.yml   # 云编译脚本
├── project.yml                    # XcodeGen 工程配置
└── Arcade/
    ├── AppDelegate.swift          # App 入口
    ├── RootViewController.swift   # WebView 壳 + 返回键注入
    ├── Info.plist                 # App 配置（最低 iOS 12、iPad、全屏）
    ├── Base.lproj/LaunchScreen.storyboard  # 启动屏
    └── Games/                     # 8 个离线 HTML 游戏
        ├── index.html             # 首页大厅
        ├── billiards.html  doudizhu.html  junqi.html
        ├── luogupan.html   minesweeper.html
        ├── tetris.html     xiangqi.html
```
