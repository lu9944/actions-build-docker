# Docker Hub 配置指南

## 为什么需要配置 Docker Hub 密钥？

作为 **Docker Pro** 用户，配置 Personal Access Token (PAT) 可以获得：

- ✅ **更高的速率限制**：从每 6 小时 100 次提升到更高限制
- ✅ **访问私有镜像**：拉取你账户下的私有镜像
- ✅ **避免匿名限制**：不再受匿名用户限制影响
- ✅ **更好的稳定性**：减少因限流导致的拉取失败

## 快速配置步骤

### 步骤 1：创建 Docker Hub Personal Access Token

1. **登录 Docker Hub**
   - 访问：https://hub.docker.com/
   - 使用你的 Docker Pro 账户登录

2. **进入账户设置**
   - 点击右上角的头像
   - 选择 **Account Settings**（账户设置）

3. **创建 Access Token**
   - 在左侧菜单选择 **Security**（安全）
   - 找到 **Access Tokens** 部分
   - 点击 **New Access Token** 按钮

4. **配置 Token**
   - **Access Token Description**: 输入描述，例如 `GitHub Actions - docker-pull-artifact`
   - **Access permissions**: 选择权限（建议选择 `Read & Write` 以获得完整功能）
   - 点击 **Generate** 生成

5. **保存 Token**
   - ⚠️ **重要**：Token 只会显示一次！请立即复制并保存到安全位置
   - Token 格式类似：`dckr_pat_abc123xyz...`

### 步骤 2：在 GitHub Repository 中配置 Secret

1. **进入你的 GitHub Repository 设置**
   - 打开使用此工作流的仓库
   - 点击 **Settings**（设置）

2. **添加 Secret**
   - 在左侧菜单选择 **Secrets and variables** → **Actions**
   - 点击 **New repository secret** 按钮
   - **Name**: 输入 `DOCKERHUB_TOKEN`
   - **Secret**: 粘贴你刚才复制的 Docker Hub Token
   - 点击 **Add secret**

   > **提示**：使用 PAT 登录时，用户名可以是任意值。但为了更清晰，你也可以添加：
   > - **Name**: `DOCKERHUB_USERNAME`（可选）
   > - **Secret**: 你的 Docker Hub 用户名

### 步骤 3：验证配置

配置完成后，运行工作流。你可以在工作流日志中看到类似信息：

```
✅ 已使用 Docker Hub Token 认证（Pro 模式）
```

如果未配置 token，日志会显示：

```
⚠️  未配置 Docker Hub Token，使用匿名模式（有限制）
```

## 工作流变化说明

配置 `DOCKERHUB_TOKEN` 后：

- ✅ 如果 token 存在：工作流会自动登录 Docker Hub
- ⚠️ 如果 token 不存在：工作流会跳过登录步骤，以匿名方式拉取（有限制）

**向后兼容**：未配置 token 的工作流仍然可以正常工作，只是使用匿名模式。

## Docker Pro 速率限制对比

| 账户类型 | 拉取限制 | 时间窗口 |
|---------|---------|---------|
| 匿名用户 | 100 次 | 6 小时 |
| 免费账户 | 200 次 | 6 小时 |
| Pro 账户 | 更高限制 | - |
| Team 账户 | 更高限制 | - |

> 注：具体的 Pro/Team 限制请参考 Docker 官方文档，可能会根据订阅级别变化。

## 安全建议

1. ✅ **使用 GitHub Secrets**：永远不要在代码中硬编码 token
2. ✅ **限制 Token 权限**：根据需要选择最小权限
3. ✅ **定期轮换**：建议每 6-12 个月更换一次 token
4. ✅ **监控使用**：在 Docker Hub 的 Security 设置中定期检查活跃的 tokens
5. ✅ **撤销不用的 Token**：删除不再使用的 access tokens

## 故障排除

### 问题：登录失败
**可能原因**：
- Token 不正确或已过期
- Token 被撤销

**解决方法**：
- 检查 token 是否正确复制（没有多余空格）
- 确认 token 未过期或被撤销
- 验证 GitHub Secret 名称是否正确（必须为 `DOCKERHUB_TOKEN`）

### 问题：仍然遇到速率限制
**可能原因**：
- Token 未生效
- 订阅已过期

**解决方法**：
- 检查工作流日志，确认是否显示 "Pro 模式"
- 检查你的 Docker Pro 订阅是否有效
- 联系 Docker 支持确认你的账户限制

### 问题：无法拉取私有镜像
**可能原因**：
- Token 权限不足
- 账户无镜像访问权限

**解决方法**：
- 确认你的 token 有 **Read** 权限
- 验证你的账户对该镜像有访问权限

## 相关链接

- [Docker Hub Access Tokens 文档](https://docs.docker.com/security/for-developers/access-tokens/)
- [Docker Hub 速率限制](https://docs.docker.com/docker-hub/download-rate-limit/)
- [GitHub Actions Secrets 文档](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
