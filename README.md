# Ansible Learn

这是一个面向初学者的 `Ansible` 学习仓库。
当前默认使用：

- `uv + .venv` 作为本地 Python / Ansible 环境
- `Incus` 容器作为被管理节点
- `Ansible` 通过 `SSH` 管理这些节点

## 推荐阅读顺序

1. `00-prestart/README.md`
2. `00-prestart/ansible.md`
3. `00-prestart/ssh.md`
4. `00-prestart/incus.md`
5. `01-quickstart/README.md`
6. `02-common-modules/README.md`
7. `03-variables-and-facts/README.md`
8. `04-conditions-loops-templates/README.md`
9. `05-group-vars-and-host-vars/README.md`
10. `06-roles/README.md`
11. `07-blocks-and-error-handling/README.md`
12. `08-tags-and-check-mode/README.md`
13. `09-imports-and-includes/README.md`
14. `10-delegation-and-run-once/README.md`
15. `11-serial-and-batches/README.md`
16. `12-hostvars-and-groups/README.md`
17. `13-asserts-and-validation/README.md`
18. `14-become-and-privilege-escalation/README.md`
19. `15-services-and-systemd/README.md`
20. `16-lineinfile-blockinfile-replace/README.md`
21. `17-archive-unarchive-fetch/README.md`
22. `18-wait-for-and-retries/README.md`
23. `19-users-and-groups/README.md`
24. `20-cron-and-scheduled-tasks/README.md`
25. `21-synchronize-and-rsync/README.md`
26. `22-secrets-and-vault/README.md`
27. `23-project-layout-and-environments/README.md`
28. `24-handlers-meta-and-flush/README.md`
29. `25-async-and-poll/README.md`
30. `26-strategy-and-failure-control/README.md`
31. `27-collections-and-galaxy/README.md`
32. `28-debugging-and-troubleshooting/README.md`

## 目录说明

- `00-prestart/`：开始实操前需要完成的本机环境准备
- `01-quickstart/`：第一章，跑通最小可用的 `Ansible + Incus` 实验环境
- `02-common-modules/`：第二章，学习常用模块和幂等性
- `03-variables-and-facts/`：第三章，学习变量、facts、`register` 和 `debug`
- `04-conditions-loops-templates/`：第四章，学习 `when`、`loop` 和 `template`
- `05-group-vars-and-host-vars/`：第五章，学习 `group_vars`、`host_vars` 和变量覆盖关系
- `06-roles/`：第六章，学习 role 的基本结构和使用方式
- `07-blocks-and-error-handling/`：第七章，学习错误处理和 block / rescue / always
- `08-tags-and-check-mode/`：第八章，学习 tags、选择性执行和 check mode
- `09-imports-and-includes/`：第九章，学习 import_tasks 和 include_tasks
- `10-delegation-and-run-once/`：第十章，学习 delegate_to 和 run_once
- `11-serial-and-batches/`：第十一章，学习 serial、批次和 run_once 的批次行为
- `12-hostvars-and-groups/`：第十二章，学习 groups、hostvars 和 set_fact
- `13-asserts-and-validation/`：第十三章，学习 assert、fail、stat 和多主机验证
- `14-become-and-privilege-escalation/`：第十四章，学习 become、become_user 和提权范围
- `15-services-and-systemd/`：第十五章，学习 service_facts、systemd_service 和服务状态管理
- `16-lineinfile-blockinfile-replace/`：第十六章，学习 lineinfile、blockinfile 和 replace
- `17-archive-unarchive-fetch/`：第十七章，学习 archive、unarchive 和 fetch
- `18-wait-for-and-retries/`：第十八章，学习 wait_for、until、retries 和 delay
- `19-users-and-groups/`：第十九章，学习 group、user、getent 和 Linux 用户组
- `20-cron-and-scheduled-tasks/`：第二十章，学习 cron 模块和定时任务管理
- `21-synchronize-and-rsync/`：第二十一章，学习 synchronize 和 rsync 风格同步
- `22-secrets-and-vault/`：第二十二章，学习 ansible-vault、敏感变量和 no_log
- `23-project-layout-and-environments/`：第二十三章，学习更真实的项目目录结构和 dev/prod 环境拆分
- `24-handlers-meta-and-flush/`：第二十四章，学习 handler、notify 和 `meta: flush_handlers`
- `25-async-and-poll/`：第二十五章，学习 async、poll、async_status 和后台任务轮询
- `26-strategy-and-failure-control/`：第二十六章，学习 strategy、any_errors_fatal 和 max_fail_percentage
- `27-collections-and-galaxy/`：第二十七章，学习 collections、FQCN、requirements.yml 和 ansible-galaxy
- `28-debugging-and-troubleshooting/`：第二十八章，学习控制端与远程主机的调试和排错思路
- `scripts/`：仓库级公共脚本，不绑定某一章

## 学习路径

- 先完成 `00-prestart/`
- 再进入 `01-quickstart/`
- 然后进入 `02-common-modules/`
- 接着进入 `03-variables-and-facts/`
- 然后进入 `04-conditions-loops-templates/`
- 然后进入 `05-group-vars-and-host-vars/`
- 然后进入 `06-roles/`
- 然后进入 `07-blocks-and-error-handling/`
- 然后进入 `08-tags-and-check-mode/`
- 然后进入 `09-imports-and-includes/`
- 然后进入 `10-delegation-and-run-once/`
- 然后进入 `11-serial-and-batches/`
- 然后进入 `12-hostvars-and-groups/`
- 然后进入 `13-asserts-and-validation/`
- 然后进入 `14-become-and-privilege-escalation/`
- 然后进入 `15-services-and-systemd/`
- 然后进入 `16-lineinfile-blockinfile-replace/`
- 然后进入 `17-archive-unarchive-fetch/`
- 然后进入 `18-wait-for-and-retries/`
- 然后进入 `19-users-and-groups/`
- 然后进入 `20-cron-and-scheduled-tasks/`
- 然后进入 `21-synchronize-and-rsync/`
- 然后进入 `22-secrets-and-vault/`
- 然后进入 `23-project-layout-and-environments/`
- 然后进入 `24-handlers-meta-and-flush/`
- 然后进入 `25-async-and-poll/`
- 然后进入 `26-strategy-and-failure-control/`
- 然后进入 `27-collections-and-galaxy/`
- 然后进入 `28-debugging-and-troubleshooting/`

## 文件约定

- 需要用户本地复制后再修改的文件，统一使用 `.example` 后缀
- 本地实际使用的文件去掉 `.example` 后缀，并加入对应目录的 `.gitignore`
- `Ansible` 示例默认使用 YAML

## 说明

- `README` 主要负责导航
- 章节里的关键学习点尽量写在 playbook、inventory、配置文件和脚本的就地注释中
