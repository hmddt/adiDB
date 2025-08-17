#!/usr/bin/env python3
"""
使用NCBI Datasets API批量下载基因序列
更直接、更可靠的方法
"""
import requests
import json
import time
import os
import zipfile
import io
from typing import List, Dict, Optional
from Bio import Entrez

# 配置NCBI访问
Entrez.email = "gsuiep02@gmail.com"
Entrez.api_key = "1e6b4f0b77de600ae84fda22a395e82a6d09"

def get_request_interval() -> float:
    """API请求间隔控制"""
    return 0.5  # 每秒最多2次请求，保守一些

def get_gene_id_by_symbol(gene_symbol: str, organism: str, max_retries: int = 3) -> Optional[int]:
    """通过基因符号获取Gene ID"""
    
    # 物种名称到taxid的映射
    taxid_map = {
        "Homo sapiens": "9606",
        "Mus musculus": "10090", 
        "Rattus norvegicus": "10116",
        "Bos taurus": "9913",
        "Gallus gallus": "9031"
    }
    
    taxid = taxid_map.get(organism)
    if not taxid:
        print(f"    ❌ 未知物种: {organism}")
        return None
    
    print(f"    🔍 搜索 {organism} 的 {gene_symbol} Gene ID...")
    
    for retry in range(max_retries):
        try:
            time.sleep(get_request_interval())
            
            # 使用Entrez搜索Gene ID
            search_term = f"{gene_symbol}[Gene Name] AND {taxid}[Taxonomy ID]"
            handle = Entrez.esearch(db="gene", term=search_term, retmax=1)
            record = Entrez.read(handle)
            handle.close()
            
            if record["IdList"]:
                gene_id = int(record["IdList"][0])
                print(f"    ✅ 找到Gene ID: {gene_id}")
                return gene_id
            else:
                print(f"    ❌ 未找到 {organism} 的 {gene_symbol}")
                return None
                
        except Exception as e:
            print(f"    ⚠️  搜索Gene ID失败 (重试 {retry+1}/{max_retries}): {e}")
            if retry < max_retries - 1:
                time.sleep(2 ** retry)
    
    return None

def download_gene_sequences_by_api(gene_id: int, gene_symbol: str, organism: str, 
                                 output_dir: str = "datasets_sequences", max_retries: int = 3) -> bool:
    """使用NCBI Datasets API下载基因序列"""
    
    # 构建API URL
    base_url = "https://api.ncbi.nlm.nih.gov/datasets/v2/gene/id"
    params = {
        "include_annotation_type": ["FASTA_RNA", "FASTA_GENE", "FASTA_PROTEIN"],
        "aux_report": "PRODUCT_REPORT",
        "table_report_type": "DATASET_REPORT"
    }
    
    url = f"{base_url}/{gene_id}/download"
    
    print(f"    📥 通过API下载 Gene ID {gene_id} 的序列...")
    print(f"    🔗 URL: {url}")
    
    for retry in range(max_retries):
        try:
            time.sleep(get_request_interval())
            
            # 发送API请求
            response = requests.get(url, params=params, timeout=60)
            
            if response.status_code == 200:
                # 创建输出目录
                gene_dir = os.path.join(output_dir, gene_symbol, organism.replace(" ", "_"))
                os.makedirs(gene_dir, exist_ok=True)
                
                # 保存ZIP文件
                zip_filename = os.path.join(gene_dir, f"{gene_symbol}_{gene_id}_dataset.zip")
                with open(zip_filename, 'wb') as f:
                    f.write(response.content)
                
                print(f"    ✅ 下载成功: {zip_filename} ({len(response.content)} 字节)")
                
                # 解压ZIP文件
                try:
                    with zipfile.ZipFile(zip_filename, 'r') as zip_ref:
                        extract_dir = os.path.join(gene_dir, f"{gene_symbol}_{gene_id}_extracted")
                        zip_ref.extractall(extract_dir)
                        
                        # 列出解压的文件
                        extracted_files = []
                        for root, dirs, files in os.walk(extract_dir):
                            for file in files:
                                if file.endswith(('.fna', '.faa', '.fasta')):
                                    extracted_files.append(os.path.join(root, file))
                        
                        print(f"    📂 解压完成，提取到 {len(extracted_files)} 个序列文件:")
                        for file_path in extracted_files[:5]:  # 只显示前5个
                            rel_path = os.path.relpath(file_path, gene_dir)
                            print(f"      - {rel_path}")
                        if len(extracted_files) > 5:
                            print(f"      ... 还有 {len(extracted_files) - 5} 个文件")
                            
                except Exception as e:
                    print(f"    ⚠️  解压失败: {e}")
                
                return True
                
            elif response.status_code == 404:
                print(f"    ❌ Gene ID {gene_id} 未找到数据")
                return False
            else:
                print(f"    ❌ API请求失败: HTTP {response.status_code}")
                if retry < max_retries - 1:
                    time.sleep(2 ** retry)
                    
        except requests.exceptions.Timeout:
            print(f"    ⏰ 请求超时 (重试 {retry+1}/{max_retries})")
            if retry < max_retries - 1:
                time.sleep(2 ** retry)
        except Exception as e:
            print(f"    ❌ 下载异常 (重试 {retry+1}/{max_retries}): {e}")
            if retry < max_retries - 1:
                time.sleep(2 ** retry)
    
    return False

def batch_download_genes_by_api(gene_symbols: List[str], species_list: List[str]):
    """批量下载多个基因的序列"""
    
    print(f"🧬 开始使用NCBI Datasets API下载 {len(gene_symbols)} 个基因在 {len(species_list)} 个物种中的序列")
    print(f"基因列表: {', '.join(gene_symbols)}")
    print(f"物种列表: {', '.join(species_list)}")
    
    total_success = 0
    total_attempts = 0
    
    for gene_symbol in gene_symbols:
        print(f"\n{'='*60}")
        print(f"📊 处理基因: {gene_symbol}")
        print(f"{'='*60}")
        
        for species in species_list:
            total_attempts += 1
            print(f"\n🔬 处理 {species} 的 {gene_symbol}:")
            
            # 步骤1: 获取Gene ID
            gene_id = get_gene_id_by_symbol(gene_symbol, species)
            if not gene_id:
                continue
            
            # 步骤2: 通过API下载序列
            success = download_gene_sequences_by_api(gene_id, gene_symbol, species)
            if success:
                total_success += 1
    
    print(f"\n🎉 批量下载完成!")
    print(f"📊 总结: 成功 {total_success}/{total_attempts} 个基因-物种组合")
    
    success_rate = (total_success / total_attempts * 100) if total_attempts > 0 else 0
    print(f"📈 成功率: {success_rate:.1f}%")

if __name__ == "__main__":
    # 检查依赖
    try:
        import requests
        print("✓ requests库可用")
    except ImportError:
        print("❌ 错误: 未安装requests，请运行: pip install requests")
        exit(1)
    
    try:
        import Bio
        print(f"✓ Biopython版本: {Bio.__version__}")
    except ImportError:
        print("❌ 错误: 未安装Biopython，请运行: pip install biopython")
        exit(1)
    
    # 配置要下载的基因和物种
    GENES = ["ABL1", "ABL2"]
    SPECIES = [
        "Homo sapiens",
        "Mus musculus", 
        "Rattus norvegicus",
        "Bos taurus",
        "Gallus gallus"
    ]
    
    print(f"📧 使用邮箱: {Entrez.email}")
    print(f"🔑 API Key: {'已设置' if Entrez.api_key else '未设置'}")
    print(f"⏱️  请求间隔: {get_request_interval():.1f}秒")
    
    # 开始批量下载
    batch_download_genes_by_api(GENES, SPECIES)
