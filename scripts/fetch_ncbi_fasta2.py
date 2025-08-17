import subprocess
import sys
import os
import time
from Bio import Entrez
from typing import List, Dict

# 配置NCBI访问 - 硬编码配置（仅个人使用）
Entrez.email = "gsuiep02@gmail.com"
Entrez.api_key = "1e6b4f0b77de600ae84fda22a395e82a6d09"

# 检查必要的依赖
def check_dependencies():
    """检查必要的Python包是否可用"""
    try:
        import Bio
        print(f"✓ Biopython版本: {Bio.__version__}")
        return True
    except ImportError:
        print("❌ 错误: 未安装Biopython，请运行: pip install biopython")
        return False


def get_accession_ids(gene_name: str, species_list: List[str], seq_type: str = "genomic", max_retries: int = 3) -> Dict[str, List[str]]:
    """根据基因名和物种列表获取对应的基因组序列登录号"""
    db_map = {
        "mrna": "nucleotide",
        "genomic": "nucleotide",
        "protein": "protein"
    }
    
    # 改进搜索策略，提供多种搜索模式
    term_suffix_map = {
        "mrna": [
            "AND mRNA[Title] AND refseq[Filter]",
            "AND mRNA[Title]",  # 备用搜索，不限制refseq
            ""  # 最宽泛的搜索
        ],
        "genomic": [
            "AND genomic[Title] AND refseq[Filter]",
            "AND (genomic[Title] OR complete genome[Title]) AND refseq[Filter]",
            "AND (genomic[Title] OR complete genome[Title])",  # 备用搜索
            ""  # 最宽泛的搜索
        ],
        "protein": [
            "AND refseq[Filter]",
            ""  # 备用搜索
        ]
    }

    db = db_map.get(seq_type, "nucleotide")
    search_terms = term_suffix_map.get(seq_type, [""])
    accession_dict = {}

    for species in species_list:
        print(f"检索 {species} 的 {gene_name} {seq_type} 序列...")
        
        # 尝试多种搜索策略
        found = False
        for i, term_suffix in enumerate(search_terms):
            if found:
                break
                
            term = f"{gene_name}[Gene Name] AND {species}[Organism] {term_suffix}"
            print(f"  尝试搜索策略 {i+1}: {term}")
            
            for retry in range(max_retries):
                try:
                    handle = Entrez.esearch(db=db, term=term, retmax=10)  # 增加返回数量
                    record = Entrez.read(handle)
                    handle.close()

                    if record["IdList"]:
                        accession_dict[species] = record["IdList"]
                        print(f"✓ 找到 {species} 的 {len(record['IdList'])} 条序列")
                        found = True
                        break
                    else:
                        print(f"  策略 {i+1} 未找到结果")
                        break  # 不需要重试，直接尝试下一个策略
                        
                except Exception as e:
                    print(f"  重试 {retry+1}/{max_retries} - 检索 {species} 出错: {e}")
                    if retry < max_retries - 1:
                        time.sleep(2 ** retry)  # 指数退避
                    else:
                        print(f"❌ {species} 检索失败，已达到最大重试次数")
        
        if not found:
            print(f"❌ 未找到 {species} 的 {gene_name} 序列（已尝试所有搜索策略）")

    return accession_dict


def download_sequences(accession_dict: Dict[str, List[str]], gene_name: str,
                       output_root: str = "genomic_sequences", max_retries: int = 3):
    """使用Biopython直接下载序列并按基因和物种分类保存"""
    if not accession_dict:
        print("❌ 没有可下载的序列")
        return False

    # 创建根目录
    gene_dir = os.path.join(output_root, gene_name)
    os.makedirs(gene_dir, exist_ok=True)
    print(f"📁 文件将保存到: {os.path.abspath(gene_dir)}")

    total_downloaded = 0
    total_failed = 0

    # 按物种下载
    for species, acc_ids in accession_dict.items():
        species_dir = os.path.join(gene_dir, species.replace(" ", "_"))
        os.makedirs(species_dir, exist_ok=True)
        
        print(f"\n📥 开始下载 {species} 的序列...")

        for i, acc in enumerate(acc_ids, 1):
            print(f"  [{i}/{len(acc_ids)}] 下载序列: {acc}")
            
            success = False
            for retry in range(max_retries):
                try:
                    # 使用Biopython的Entrez.efetch直接下载FASTA序列
                    handle = Entrez.efetch(db="nucleotide", id=acc, rettype="fasta", retmode="text")
                    fasta_content = handle.read()
                    handle.close()
                    
                    if fasta_content.strip():
                        # 保存FASTA文件
                        filename = f"{acc}.fasta"
                        filepath = os.path.join(species_dir, filename)
                        
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(fasta_content)
                        
                        print(f"    ✓ 下载成功: {filename}")
                        total_downloaded += 1
                        success = True
                        break
                    else:
                        print(f"    ❌ 下载失败: 空内容 (重试 {retry+1}/{max_retries})")
                        if retry < max_retries - 1:
                            time.sleep(2 ** retry)  # 指数退避
                            
                except Exception as e:
                    print(f"    ❌ 下载异常 (重试 {retry+1}/{max_retries}): {e}")
                    if retry < max_retries - 1:
                        time.sleep(2 ** retry)
                    else:
                        print(f"    ❌ {acc} 下载失败，已达到最大重试次数")
            
            if not success:
                total_failed += 1

    print(f"\n📊 下载统计: 成功 {total_downloaded} 个，失败 {total_failed} 个")
    return total_downloaded > 0


if __name__ == "__main__":
    # 首先检查依赖
    print("🔍 检查依赖...")
    if not check_dependencies():
        print("\n❌ 依赖检查失败，请安装必要的包后重试")
        sys.exit(1)
    
    # 显示NCBI配置信息
    print(f"📧 使用邮箱: {Entrez.email}")
    print(f"🔑 API Key: {'已设置' if Entrez.api_key else '未设置'}")
    print("✅ NCBI配置完成")

    GENES = ["ABL1", "ABL2"]
    SPECIES = [
        "Homo sapiens",      # 人
        "Mus musculus",      # 小鼠
        "Rattus norvegicus", # 大鼠
        "Bos taurus",        # 牛
        "Gallus gallus"      # 鸡
    ]
    SEQ_TYPE = "genomic"  # 下载基因组序列

    print(f"\n🧬 准备下载 {len(GENES)} 个基因在 {len(SPECIES)} 个物种中的 {SEQ_TYPE} 序列")
    print(f"基因列表: {', '.join(GENES)}")
    
    total_success = 0
    total_genes = len(GENES)

    for i, gene in enumerate(GENES, 1):
        print(f"\n{'='*60}")
        print(f"📊 进度: [{i}/{total_genes}] 处理基因: {gene}")
        print(f"{'='*60}")
        
        accessions = get_accession_ids(gene, SPECIES, SEQ_TYPE)
        if accessions:
            success = download_sequences(accessions, gene)
            if success:
                total_success += 1
        else:
            print(f"❌ 未找到 {gene} 的任何序列")

    print(f"\n🎉 任务完成!")
    print(f"📊 总结: 成功处理 {total_success}/{total_genes} 个基因")
    
    if total_success < total_genes:
        print("💡 提示: 如果某些基因未找到序列，可以尝试:")
        print("   1. 检查基因名是否正确")
        print("   2. 尝试使用基因的别名")
        print("   3. 修改搜索类型 (genomic -> mrna)")
        print("   4. 检查网络连接和NCBI服务状态")
