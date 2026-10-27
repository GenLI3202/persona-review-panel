# persona-review-panel · 人物评审团

把一份材料（方案、产品、文档、设计、代码、论文）同时交给几位"人物审阅官"——乔布斯、马斯克、费曼、Karpathy、Ilya Sutskever、张一鸣——各自**独立、并行**审阅，再由主会话汇总**共识与分歧**。支持 Claude Code 和 Codex。

> An orchestration layer for [Claude Code](https://code.claude.com) and Codex that turns existing persona skills into read-only, parallel reviewer agents and synthesizes where they agree and disagree. The persona skills themselves are **not** part of this repo — see [Attribution](#来源与原创说明--attribution).

## 来源与原创说明 / Attribution

本仓库**只包含原创的编排层**。人物视角本身来自花叔（[@alchaincyf](https://github.com/alchaincyf)）用 [女娲 nuwa-skill](https://github.com/alchaincyf/nuwa-skill) 蒸馏的 skill，均为 MIT 许可。本仓库不复制、不修改它们，安装时直接从原仓库拉取。

### 本仓库原创（与 Claude 协作编写）

| 部分 | 位置 | 做了什么 |
|---|---|---|
| 评审团 skill | [`skills/persona-panel/SKILL.md`](skills/persona-panel/SKILL.md) | 选人规则、自足 brief、并行派发（Claude / Codex 两种写法）、"共识 / 分歧 / 独到问题 / 下一步"汇总格式 |
| 6 个只读审阅 agent（Claude） | [`agents/claude/`](agents/claude/) | 每个 agent 用 `skills:` 预载一个人物 skill，只给 Read / Grep / Glob，统一输出格式 |
| 6 个只读审阅 agent（Codex） | [`agents/codex/`](agents/codex/) | 同上；Codex 没有预载字段，改为指令里先读对应 `SKILL.md` |
| 生成脚本 | [`scripts/generate_agents.py`](scripts/generate_agents.py) | 从一张人物表生成上面 12 个文件，加新人物只需加一行 |
| 安装脚本 | [`install.sh`](install.sh) | 先从原仓库安装 6 个人物 skill，再装本仓库的 skill 和 agent |

### 依赖的上游 skill（非本仓库内容）

| 人物 | skill 名 | 原仓库 | 作者 / 许可 |
|---|---|---|---|
| 费曼 | `feynman-perspective` | [alchaincyf/feynman-skill](https://github.com/alchaincyf/feynman-skill) | 花叔 / MIT |
| 乔布斯 | `steve-jobs-perspective` | [alchaincyf/steve-jobs-skill](https://github.com/alchaincyf/steve-jobs-skill) | 花叔 / MIT |
| Karpathy | `andrej-karpathy-perspective` | [alchaincyf/karpathy-skill](https://github.com/alchaincyf/karpathy-skill) | 花叔 / MIT |
| Ilya Sutskever | `ilya-sutskever-perspective` | [alchaincyf/ilya-sutskever-skill](https://github.com/alchaincyf/ilya-sutskever-skill) | 花叔 / MIT |
| 张一鸣 | `zhang-yiming-perspective` | [alchaincyf/zhang-yiming-skill](https://github.com/alchaincyf/zhang-yiming-skill) | 花叔 / MIT |
| 马斯克 | `elon-musk-perspective` | [alchaincyf/elon-musk-skill](https://github.com/alchaincyf/elon-musk-skill) | 花叔 / MIT |

方法论来源：[alchaincyf/nuwa-skill](https://github.com/alchaincyf/nuwa-skill)（女娲，人物 skill 蒸馏框架）。人物 skill 是基于公开资料的模拟视角，不代表本人观点。

## 安装

```bash
git clone https://github.com/GenLI3202/persona-review-panel.git
cd persona-review-panel
./install.sh
```

装到的位置：

| 内容 | Claude Code | Codex |
|---|---|---|
| 6 个人物 skill（上游） | `~/.claude/skills/`（软链接） | `~/.agents/skills/` |
| `persona-panel` skill | `~/.claude/skills/persona-panel`（软链接） | `~/.agents/skills/persona-panel` |
| 审阅 agent | `~/.claude/agents/personas/` | `~/.codex/agents/` |

## 使用

- 「评审团，让乔布斯和张一鸣审一下 `docs/plan.md`」
- 「请几位人物审一下这个方案：最大的风险是什么？」（不点名时自动挑 3 位最相关的）
- Claude Code 里也可以直接 `/persona-panel`

每位审阅官输出：一句话判断、最致命的 3 个问题、会砍掉什么、会追问你什么、诚实边界。汇总时重点是**分歧表**：谁持什么立场、根源是哪个心智模型不同、需要你拍板什么。

想追问某一位：Claude Code 里继续给那个 agent 发消息；Codex 在那个 agent 的线程里继续。想和某位人物长聊，直接用对应的 perspective skill，不走评审团。

## 成本

每位审阅官要装载约 1 万多 token 的人设，再读一次材料。一次请 3 位大约是 3 倍消耗。Claude 版默认 `model: sonnet`，可在 `agents/claude/*.md` 中修改。

## 只读的保证程度

- **Claude Code**：工具白名单只有 Read / Grep / Glob，无法写文件，也无法调用其他 skill。
- **Codex**：agent 文件不支持单独设置沙箱，只读靠指令约束，实际权限沿用主会话；需要硬保证时用 `-s read-only` 启动 Codex。

## 扩展评审团 / Extending the panel

默认评审团只用了 6 位。女娲官方一共发布了 15 个 skill（14 位人物 + 1 个主题），都可以按下面"添加新人物"的步骤加进来。分数是作者用双 agent 盲测给出的保真度评分（方法见 [fidelity-scorecard.md](https://github.com/alchaincyf/nuwa-skill/blob/main/references/fidelity-scorecard.md)），不是第三方评测。

The default panel uses 6 personas. Nuwa's author has published 15 official skills (14 people + 1 topic); any of them can be added via the steps below. Scores are the author's own blind-test fidelity ratings, not an independent benchmark.

| 分数 Score | Skill | 领域 | Domain | 原仓库 Source | 默认评审团 Default |
|---|---|---|---|---|---|
| 97 | MrBeast | 内容创造 / YouTube 方法论 | Content creation / YouTube | [mrbeast-skill](https://github.com/alchaincyf/mrbeast-skill) | |
| 97 | 纳瓦尔 Naval | 财富 / 杠杆 / 人生哲学 | Wealth / leverage / life philosophy | [naval-skill](https://github.com/alchaincyf/naval-skill) | |
| 97 | 塔勒布 Taleb | 风险 / 反脆弱 / 不确定性 | Risk / antifragility / uncertainty | [taleb-skill](https://github.com/alchaincyf/taleb-skill) | |
| 97 | 乔布斯 Steve Jobs | 产品 / 设计 / 战略 | Product / design / strategy | [steve-jobs-skill](https://github.com/alchaincyf/steve-jobs-skill) | ✓ |
| 97 | Karpathy | AI / 工程 / 教育 / 开源 | AI / engineering / education / open source | [karpathy-skill](https://github.com/alchaincyf/karpathy-skill) | ✓ |
| 97 | Paul Graham | 创业 / 写作 / 产品 | Startups / writing / product | [paul-graham-skill](https://github.com/alchaincyf/paul-graham-skill) | |
| 97 | 张雪峰 Zhang Xuefeng | 教育选择 / 职业规划 | Education choices / career planning | [zhangxuefeng-skill](https://github.com/alchaincyf/zhangxuefeng-skill) | |
| 96 | 芒格 Munger | 投资 / 多元思维 / 逆向思考 | Investing / mental models / inversion | [munger-skill](https://github.com/alchaincyf/munger-skill) | |
| 96 | 费曼 Feynman | 学习 / 教学 / 科学思维 | Learning / teaching / scientific thinking | [feynman-skill](https://github.com/alchaincyf/feynman-skill) | ✓ |
| 96 | X导师 X Mentor（主题 topic） | X/Twitter 运营 | X/Twitter growth | [x-mentor-skill](https://github.com/alchaincyf/x-mentor-skill) | |
| 95 | 特朗普 Trump | 谈判 / 权力 / 传播 | Negotiation / power / communication | [trump-skill](https://github.com/alchaincyf/trump-skill) | |
| 94 | Ilya Sutskever | AI 安全 / scaling / 研究品味 | AI safety / scaling / research taste | [ilya-sutskever-skill](https://github.com/alchaincyf/ilya-sutskever-skill) | ✓ |
| 93 | 张一鸣 Zhang Yiming | 产品 / 组织 / 全球化 | Product / organization / globalization | [zhang-yiming-skill](https://github.com/alchaincyf/zhang-yiming-skill) | ✓ |
| 91 | 孙宇晨 Justin Sun | 营销 / 注意力经济 / 叙事 | Marketing / attention economy / narrative | [nuwa-skill examples/](https://github.com/alchaincyf/nuwa-skill/tree/main/examples/sun-yuchen-perspective)（无独立仓库 no standalone repo） | |
| 89 | 马斯克 Elon Musk | 工程 / 成本 / 第一性原理 | Engineering / cost / first principles | [elon-musk-skill](https://github.com/alchaincyf/elon-musk-skill) | ✓ |

安装任意一个 / Install any of them: `npx skills add alchaincyf/<repo> -g -a claude-code -a codex`。社区还有更多人物合集，见 nuwa 的 [COMMUNITY.md](https://github.com/alchaincyf/nuwa-skill/blob/main/COMMUNITY.md)（未经审计，使用前自行甄别 / unaudited）。

## 添加新人物

1. 用女娲蒸馏，或安装一个现成的 perspective skill。
2. 在 `scripts/generate_agents.py` 的 `PERSONAS` 里加一行（agent 名、显示名、skill 名、擅长审的方向）。
3. 运行 `python3 scripts/generate_agents.py`，并在 `skills/persona-panel/SKILL.md` 的名单表里加一行。

## License

本仓库原创部分采用 [MIT](LICENSE)。上游人物 skill 各自遵循其原仓库的许可（均为 MIT，版权归 Huashu 花叔）。
