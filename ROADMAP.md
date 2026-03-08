# Ansible 学习路线

## 目标

- 争取在 `30` 章前后把 `Ansible` 基础系统学完。
- `31+` 开始结合 `Kubernetes / k3s` 做真实项目。

## 22 ~ 30 规划

- `22-secrets-and-vault`
  - 学 `ansible-vault`
  - 学敏感变量、密码、Token 的管理方式

- `23-project-layout-and-environments`
  - 学更真实的项目目录结构
  - 学 `dev` / `prod` 环境拆分

- `24-handlers-meta-and-flush`
  - 学更完整的 handler 执行机制
  - 学 `meta: flush_handlers`

- `25-async-and-poll`
  - 学异步任务
  - 学长时间任务的轮询方式

- `26-strategy-and-failure-control`
  - 学批量执行时的失败控制
  - 学 `strategy`、`any_errors_fatal`、`max_fail_percentage`

- `27-collections-and-galaxy`
  - 学 `collections`
  - 学 `requirements.yml`
  - 学 `ansible-galaxy`

- `28-debugging-and-troubleshooting`
  - 学更系统的排错方法
  - 学怎么观察输出、定位问题

- `29-best-practices-and-lint`
  - 学项目规范和可维护性
  - 学 `ansible-lint`

- `30-mini-project`
  - 做一个综合项目
  - 把前面学过的内容串起来

## 31+ 方向

- `31-k8s-node-bootstrap`
- `32-install-container-runtime`
- `33-install-k3s`
- `34-k8s-app-deploy-with-ansible`

## 当前建议

- 下一章从 `22-secrets-and-vault` 开始。
- 先把 `Ansible` 的安全与项目化能力补齐，再进入 `Kubernetes`。
