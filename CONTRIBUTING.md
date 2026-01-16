# 贡献指南

感谢你对 `docker-pull-artifact` 项目的关注！我们欢迎各种形式的贡献。

## 如何贡献

### 报告 Bug

如果你发现了 Bug，请：

1. 在 [Issues](../../issues) 中搜索是否已有相关问题
2. 如果没有，创建新的 Issue，包含以下信息：
   - 问题描述
   - 复现步骤
   - 期望的行为
   - 实际的行为
   - 环境信息（操作系统、Docker 版本等）

### 提出新功能

如果你有新的功能建议：

1. 先在 [Issues](../../issues) 中讨论你的想法
2. 等待维护者反馈
3. 得到认可后再开始开发

### 提交代码

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 代码规范

### YAML 格式

- 使用 2 个空格缩进
- 使用 LF 换行符
- 在工作流文件中添加清晰的注释

### 提交信息

使用清晰的提交信息格式：

```
类型(范围): 简短描述

详细描述（可选）
```

类型可以是：
- `feat`: 新功能
- `fix`: 修复 Bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具相关

示例：

```
feat(workflow): add support for ARM64 architecture

fix(workflow): correct artifact naming pattern

docs(readme): update usage examples
```

## Pull Request 检查清单

提交 PR 前，请确认：

- [ ] 代码符合项目的代码规范
- [ ] 已添加必要的注释
- [ ] 已更新相关文档（如需要）
- [ ] PR 描述清晰说明了更改内容
- [ ] 所有 CI 检查通过

## 行为准则

请尊重所有贡献者，保持友好和专业的交流方式。

## 联系方式

如有任何问题，请通过 [Issues](../../issues) 或 [Discussions](../../discussions) 联系我们。

---

再次感谢你的贡献！
