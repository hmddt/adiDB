# NCBI序列批量下载工具使用说明

## 概述
`fetch_ncbi_fasta2.py` 是一个改进的NCBI序列批量下载工具，支持从NCBI数据库下载指定基因在多个物种中的基因组、mRNA或蛋白质序列。

## 主要改进

### 🔧 修复的问题
1. **安全性**: 移除硬编码的API密钥，改用环境变量
2. **依赖检查**: 添加自动依赖检查，确保必要工具已安装
3. **搜索策略**: 改进搜索算法，提供多种搜索模式以提高成功率
4. **错误处理**: 添加重试机制和详细的错误信息
5. **用户体验**: 添加进度显示和统计信息

### 🚀 新功能
- 多重搜索策略（从严格到宽松）
- 指数退避重试机制
- **智能频率控制**：自动遵守NCBI请求限制
- **批量下载**：每批最多5个序列，避免过载
- **长序列处理**：智能超时机制，防止大序列下载卡住
- **进度监控**：实时显示下载进度和序列大小
- 详细的进度和统计报告
- 环境变量配置支持

## 安装依赖

```bash
# 只需要安装Biopython
pip install biopython

# 或使用conda
conda install -c bioconda biopython
```

## 环境配置

### 设置NCBI邮箱（推荐）
```bash
export NCBI_EMAIL="your_email@example.com"
```

### 设置API密钥（可选但推荐）
1. 访问 https://www.ncbi.nlm.nih.gov/account/settings/
2. 获取API密钥
3. 设置环境变量：
```bash
export NCBI_API_KEY="your_api_key_here"
```

## 使用方法

### 快速开始 - 下载ABL1基因FASTA序列

#### 1. 设置环境变量（推荐）
```bash
# 设置NCBI邮箱
export NCBI_EMAIL="your_email@example.com"

# 设置API密钥（可选，但推荐）
export NCBI_API_KEY="your_api_key_here"
```

#### 2. 运行脚本下载ABL1基因
```bash
# 进入脚本目录
cd /Users/linjiezhao/projects/adiDB/scripts

# 运行脚本（默认会下载ABL1和ABL2基因）
python fetch_ncbi_fasta2.py
```

#### 3. 只下载ABL1基因的方法
如果只想下载ABL1基因，请修改脚本中的基因列表：

```python
# 在脚本中找到这一行并修改：
GENES = ["ABL1"]  # 只下载ABL1基因
```

然后运行：
```bash
python fetch_ncbi_fasta2.py
```

#### 4. 一行命令下载ABL1基因
```bash
# 临时修改基因列表并运行
python -c "
import sys
sys.path.append('.')
exec(open('fetch_ncbi_fasta2.py').read().replace('GENES = [\"ABL1\", \"ABL2\"]', 'GENES = [\"ABL1\"]'))
"
```

### 完整命令示例

```bash
# 完整的命令序列
cd /Users/linjiezhao/projects/adiDB/scripts
export NCBI_EMAIL="your_email@example.com"
export NCBI_API_KEY="your_api_key_here"  # 可选
python fetch_ncbi_fasta2.py
```

### 自定义配置
如需下载其他基因或物种，编辑脚本中的以下变量：

```python
GENES = ["ABL1"]  # 要下载的基因列表
SPECIES = [
    "Homo sapiens",      # 人
    "Mus musculus",      # 小鼠
    "Rattus norvegicus", # 大鼠
    "Bos taurus",        # 牛
    "Gallus gallus"      # 鸡
]
SEQ_TYPE = "genomic"  # 序列类型: "genomic", "mrna", "protein"
```

## 输出结构

```
genomic_sequences/
├── ABL1/
│   ├── Homo_sapiens/
│   │   ├── NC_000009.12.fasta
│   │   └── ...
│   ├── Mus_musculus/
│   │   └── ...
│   └── ...
└── ABL2/
    └── ...
```

## 搜索策略

工具会按以下顺序尝试搜索策略：

### 基因组序列 (genomic)
1. `基因名[Gene Name] AND 物种[Organism] AND genomic[Title] AND refseq[Filter]`
2. `基因名[Gene Name] AND 物种[Organism] AND (genomic[Title] OR complete genome[Title]) AND refseq[Filter]`
3. `基因名[Gene Name] AND 物种[Organism] AND (genomic[Title] OR complete genome[Title])`
4. `基因名[Gene Name] AND 物种[Organism]` (最宽泛搜索)

### mRNA序列
1. `基因名[Gene Name] AND 物种[Organism] AND mRNA[Title] AND refseq[Filter]`
2. `基因名[Gene Name] AND 物种[Organism] AND mRNA[Title]`
3. `基因名[Gene Name] AND 物种[Organism]`

## 故障排除

### 常见问题

1. **找不到序列**
   - 检查基因名拼写
   - 尝试基因的别名或同义词
   - 更换序列类型（genomic → mrna）

2. **下载失败**
   - 检查网络连接
   - 确认NCBI服务状态
   - 设置API密钥以提高请求限制

3. **依赖问题**
   ```bash
   # 重新安装Biopython
   pip install --upgrade biopython
   ```

### 错误代码含义

- `❌ 依赖检查失败`: 缺少必要的Python包
- `❌ 下载失败`: 网络或NCBI服务问题
- `⏰ 下载超时`: 单个文件下载超过60秒
- `❌ 检索失败`: NCBI搜索API调用失败

## 性能优化与频率控制

### 🚦 NCBI请求频率限制
- **有API密钥**: 每秒最多10次请求 (0.12秒间隔)
- **无API密钥**: 每秒最多3次请求 (0.4秒间隔)
- **批量处理**: 每批5个序列，批次间额外暂停
- **智能重试**: 检测到频率限制时自动延长等待时间

### ⏱️ 长序列超时处理
- **基因组序列** (NC_, NT_, NW_): 90秒超时
- **mRNA序列** (NM_, NR_): 60秒超时
- **其他序列**: 30秒超时
- **动态调整**: 超时后自动延长等待时间
- **进度显示**: 实时显示下载状态和序列长度

### 💡 优化建议
1. **设置API密钥**: 大幅提高下载速度
2. **网络环境**: 使用稳定的网络连接
3. **分批处理**: 脚本自动分批，无需手动干预
4. **耐心等待**: 大量序列下载需要时间，这是正常的

## 注意事项

- 请遵守NCBI的使用条款和频率限制
- 大量下载时建议设置API密钥
- 某些基因可能在特定物种中不存在
- 下载的序列质量取决于NCBI数据库的内容

## 联系支持

如果遇到问题，请检查：
1. 网络连接
2. NCBI服务状态
3. 基因名称正确性
4. 依赖包版本兼容性
