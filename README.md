# 析造 Agent 下载

适用于 macOS Apple Silicon（M 系列芯片）。本页只发布客户端安装文件，不包含用户密钥、会话记录或项目源码。

下载 Release 中的 `Xizao-Install.command`（显示名“安装析造Agent.command”），双击运行。首次联网下载完整客户端并安装到用户的 Applications 文件夹，随后打开应用。应用内填写自己的 DeepSeek 密钥并测试连接。已有客户端正在运行时，请先退出。

安装入口约几 KB；首次需要下载约 148 MB 的客户端本体。完成后不再重复下载该版本。模型使用仍需要网络与有效的 DeepSeek API Key。

也可下载 DMG 后，将“析造Agent”拖入 Applications。本构建使用本地临时签名，未经过 Apple 公证；仅在确认来源后使用 macOS 正常提供的允许打开选项。

## SHA256

`Xizao-macOS-arm64-1.4.0-compact-20261009.dmg`

`17e2289819be51d27029ba0a368b66ecedd1a6973ad84070b6c2bbd72123f22d`

实测范围：打包编排服务、空会话、真实 DeepSeek CSV 分析；未在另一台全新 Mac 上验证完整首次安装流程。
