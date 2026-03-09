# Ansible + Incus 11: Serial and Batches

这一节建立在 `10-delegation-and-run-once` 的基础上，继续学习 `serial`、`ansible_play_batch` 和“分批执行时的 `run_once`”。

## 文件

- `prepare.sh`：复制 `10-delegation-and-run-once` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `serial_and_batches.yml`：这一章的示例 playbook
- `controller-output/`：运行时在控制端生成的本地输出目录，不提交到 Git

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `11-serial-and-batches` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 11-serial-and-batches
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `10-delegation-and-run-once/prepare.sh`
- `10-delegation-and-run-once/delegation_and_run_once.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook serial_and_batches.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook serial_and_batches.yml` 可以成功执行
- 你能看懂 `serial`、`ansible_play_batch`，以及为什么分批执行时 `run_once` 会变成“每批一次”
