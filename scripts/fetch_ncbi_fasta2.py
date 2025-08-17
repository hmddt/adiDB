import subprocess
import sys
import os
from Bio import Entrez
from typing import List, Dict

# 配置NCBI访问
Entrez.email = "gsuiep02@gmail.com"
Entrez.api_key = "1e6b4f0b77de600ae84fda22a395e82a6d09"


def get_accession_ids(gene_name: str, species_list: List[str], seq_type: str = "genomic") -> Dict[str, List[str]]:
    """根据基因名和物种列表获取对应的基因组序列登录号"""
    db_map = {
        "mrna": "nucleotide",
        "genomic": "nucleotide",
        "protein": "protein"
    }
    term_suffix_map = {
        "mrna": "AND mRNA[Title] AND refseq[Filter]",
        "genomic": "AND genomic[Title] AND refseq[Filter]",  # 筛选基因组序列
        "protein": "AND refseq[Filter]"
    }

    db = db_map.get(seq_type, "nucleotide")
    term_suffix = term_suffix_map.get(seq_type, "")
    accession_dict = {}

    for species in species_list:
        print(f"检索 {species} 的 {gene_name} {seq_type} 序列...")
        term = f"{gene_name}[Gene Name] AND {species}[Organism] {term_suffix}"
        try:
            handle = Entrez.esearch(db=db, term=term, retmax=5)  # 每个物种最多返回5条参考序列
            record = Entrez.read(handle)
            handle.close()

            if record["IdList"]:
                accession_dict[species] = record["IdList"]
                print(f"找到 {species} 的 {len(record['IdList'])} 条序列")
            else:
                print(f"未找到 {species} 的 {gene_name} 序列")
        except Exception as e:
            print(f"检索 {species} 出错: {e}", file=sys.stderr)

    return accession_dict


def download_sequences(accession_dict: Dict[str, List[str]], gene_name: str,
                       output_root: str = "abl_genomic_sequences"):
    """下载基因组序列并按基因和物种分类保存"""
    try:
        # 检查工具是否可通过Python调用
        subprocess.run(
            [sys.executable, "-m", "ncbi_acc_download", "--version"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
    except Exception as e:
        print(f"错误: 无法找到ncbi-acc-download，请确保已在当前环境安装: {e}", file=sys.stderr)
        return

    # 创建根目录（区分基因组序列）
    gene_dir = os.path.join(output_root, gene_name)
    os.makedirs(gene_dir, exist_ok=True)
    print(f"基因组文件将保存到: {os.path.abspath(gene_dir)}")

    # 按物种下载
    for species, acc_ids in accession_dict.items():
        species_dir = os.path.join(gene_dir, species.replace(" ", "_"))
        os.makedirs(species_dir, exist_ok=True)

        for acc in acc_ids:
            print(f"下载 {species} {gene_name} 基因组序列: {acc}")
            try:
                result = subprocess.run(
                    [sys.executable, "-m", "ncbi_acc_download", "--format", "fasta", "--out", species_dir, acc],
                    capture_output=True,
                    text=True
                )
                if result.returncode != 0:
                    print(f"下载 {acc} 失败，返回码: {result.returncode}")
                    print(f"错误输出: {result.stderr}")
                else:
                    print(f"下载 {acc} 成功")
            except Exception as e:
                print(f"下载 {acc} 发生异常: {e}", file=sys.stderr)


if __name__ == "__main__":
    GENES = ["ABL1", "ABL2"]
    SPECIES = [
        "Homo sapiens",  # 人
        "Mus musculus",  # 小鼠
        "Rattus norvegicus",  # 大鼠
        "Bos taurus",  # 牛
        "Gallus gallus"  # 鸡
    ]
    SEQ_TYPE = "genomic"  # 关键修改：下载基因组序列

    for gene in GENES:
        print(f"\n===== 开始处理基因: {gene} 基因组序列 =====")
        accessions = get_accession_ids(gene, SPECIES, SEQ_TYPE)
        if accessions:
            download_sequences(accessions, gene)
        else:
            print(f"未找到 {gene} 的任何基因组序列")

    print("\n所有基因组序列下载任务完成")
