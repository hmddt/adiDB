import subprocess
import sys
import os
import time
import socket
from Bio import Entrez
from typing import List, Dict

# 配置NCBI访问 - 硬编码配置（仅个人使用）
Entrez.email = "gsuiep02@gmail.com"
Entrez.api_key = "1e6b4f0b77de600ae84fda22a395e82a6d09"

def get_request_interval() -> float:
    """根据API密钥状态返回推荐的请求间隔"""
    return 0.12 if Entrez.api_key else 0.4  # 有API密钥时每秒最多10次，无密钥时每秒最多3次

def download_with_simple_timeout(acc_id: str, timeout_seconds: int):
    """带调试信息的超时下载，找出阻塞点"""
    
    original_timeout = socket.getdefaulttimeout()
    
    try:
        # 设置更短的socket超时，避免长时间阻塞
        socket.setdefaulttimeout(min(timeout_seconds, 15))  # 最多15秒socket超时
        print(f"        🔄 开始下载，socket超时: {min(timeout_seconds, 15)}秒")
        
        start_time = time.time()
        
        # 步骤1: 建立连接
        print(f"        📡 正在建立连接...")
        handle = Entrez.efetch(db="nucleotide", id=acc_id, rettype="fasta", retmode="text")
        step1_time = time.time() - start_time
        print(f"        ✅ 连接建立完成，耗时: {step1_time:.1f}秒")
        
        # 步骤2: 读取数据
        print(f"        📥 正在读取数据...")
        read_start = time.time()
        
        # 分块读取，但有总时间限制
        content = ""
        chunk_count = 0
        while True:
            total_elapsed = time.time() - start_time
            if total_elapsed > timeout_seconds:
                print(f"        ⏰ 总时间超时，强制停止 (耗时: {total_elapsed:.1f}秒)")
                break
                
            try:
                chunk = handle.read(32768)  # 32KB块
                if not chunk:
                    break
                content += chunk
                chunk_count += 1
                
                if chunk_count % 20 == 0:  # 每20块显示一次进度
                    chunk_elapsed = time.time() - read_start
                    size_mb = len(content) / 1024 / 1024
                    speed_mbps = size_mb / chunk_elapsed if chunk_elapsed > 0 else 0
                    print(f"        📊 已读取 {chunk_count} 块，{size_mb:.1f}MB，速度: {speed_mbps:.1f}MB/s")
                    
            except socket.timeout:
                print(f"        ⏰ 读取数据时socket超时")
                break
            except Exception as e:
                print(f"        ❌ 读取数据时出错: {e}")
                break
        
        read_time = time.time() - read_start
        print(f"        ✅ 数据读取完成，耗时: {read_time:.1f}秒，共 {chunk_count} 块")
        
        # 步骤3: 关闭连接
        print(f"        🔒 正在关闭连接...")
        close_start = time.time()
        try:
            handle.close()
            close_time = time.time() - close_start
            print(f"        ✅ 连接关闭完成，耗时: {close_time:.1f}秒")
        except Exception as e:
            print(f"        ⚠️  关闭连接时出错: {e}")
        
        total_elapsed = time.time() - start_time
        print(f"        🎉 下载完成，总耗时: {total_elapsed:.1f}秒，内容大小: {len(content)} 字节")
        
        if content.strip():
            return content
        else:
            raise TimeoutError(f"下载内容为空 (耗时: {total_elapsed:.1f}秒)")
        
    except KeyboardInterrupt:
        # 捕获Ctrl+C，说明用户手动中断了卡住的下载
        elapsed = time.time() - start_time
        print(f"        ⚠️  用户中断下载，耗时: {elapsed:.1f}秒")
        print(f"        💡 检测到手动中断，可能socket超时未生效")
        # 将手动中断转换为超时异常，让程序继续运行
        raise TimeoutError(f"手动中断转超时 (耗时: {elapsed:.1f}秒)")
        
    except socket.timeout:
        elapsed = time.time() - start_time
        print(f"        ⏰ Socket超时，耗时: {elapsed:.1f}秒")
        raise TimeoutError(f"Socket超时 (耗时: {elapsed:.1f}秒)")
        
    except Exception as e:
        elapsed = time.time() - start_time
        if "timeout" in str(e).lower() or "timed out" in str(e).lower():
            print(f"        ⏰ 网络超时，耗时: {elapsed:.1f}秒")
            raise TimeoutError(f"网络超时 (耗时: {elapsed:.1f}秒)")
        else:
            print(f"        ❌ 其他错误: {e}")
            raise e
            
    finally:
        # 恢复原始超时设置
        socket.setdefaulttimeout(original_timeout)

def estimate_download_time(acc_id: str) -> int:
    """根据序列ID估算下载超时时间"""
    # 基因组序列需要更长时间
    if any(prefix in acc_id for prefix in ['NC_', 'NT_', 'NW_']):
        return 120  # 基因组序列2分钟
    elif any(prefix in acc_id for prefix in ['NM_', 'NR_']):
        return 60   # mRNA序列1分钟
    else:
        return 30   # 其他序列30秒

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
            "AND refseq[Filter] AND gene[Title]",  # 优先搜索基因序列
            "AND genomic[Title] AND refseq[Filter]",
            "AND (genomic[Title] OR complete genome[Title]) AND refseq[Filter]",
            "AND refseq[Filter]",  # RefSeq数据库中的所有相关序列
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
                    # 添加请求间隔以遵守NCBI频率限制
                    time.sleep(get_request_interval())
                    
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

        # 批量下载，每批最多5个序列
        batch_size = 5
        for batch_start in range(0, len(acc_ids), batch_size):
            batch_end = min(batch_start + batch_size, len(acc_ids))
            batch_ids = acc_ids[batch_start:batch_end]
            
            print(f"  📦 批次 {batch_start//batch_size + 1}: 下载 {len(batch_ids)} 个序列")
            
            for i, acc in enumerate(batch_ids, batch_start + 1):
                # 估算超时时间
                timeout_seconds = estimate_download_time(acc)
                seq_type = "基因组" if acc.startswith(('NC_', 'NT_', 'NW_')) else "mRNA" if acc.startswith(('NM_', 'NR_')) else "其他"
                
                print(f"    [{i}/{len(acc_ids)}] 下载{seq_type}序列: {acc} (超时: {timeout_seconds}s)")
                
                success = False
                for retry in range(max_retries):
                    try:
                        # 添加请求间隔以遵守NCBI频率限制
                        time.sleep(get_request_interval())
                        
                        # 使用简单粗暴的超时下载
                        fasta_content = download_with_simple_timeout(acc, timeout_seconds)
                        
                        if fasta_content.strip():
                            # 计算序列长度（去除FASTA头部和换行符）
                            lines = fasta_content.strip().split('\n')
                            seq_lines = [line for line in lines if not line.startswith('>')]
                            seq_length = sum(len(line.strip()) for line in seq_lines)
                            
                            # 保存FASTA文件
                            filename = f"{acc}.fasta"
                            filepath = os.path.join(species_dir, filename)
                            
                            with open(filepath, 'w', encoding='utf-8') as f:
                                f.write(fasta_content)
                            
                            # 根据序列长度显示不同信息
                            if seq_length > 1000000:  # 超过1MB
                                size_info = f"长度: {seq_length:,} bp (大序列)"
                            elif seq_length > 100000:  # 超过100KB
                                size_info = f"长度: {seq_length:,} bp (中等)"
                            else:
                                size_info = f"长度: {seq_length:,} bp"
                            
                            print(f"      ✓ 下载成功: {filename} ({size_info})")
                            total_downloaded += 1
                            success = True
                            break
                        else:
                            print(f"      ❌ 下载失败: 空内容 (重试 {retry+1}/{max_retries})")
                            if retry < max_retries - 1:
                                time.sleep(2 ** retry)  # 指数退避
                    
                    except TimeoutError as e:
                        print(f"      ⏰ 下载超时: {e} (重试 {retry+1}/{max_retries})")
                        if retry < max_retries - 1:
                            # 超时后稍微增加等待时间
                            old_timeout = timeout_seconds
                            timeout_seconds = min(timeout_seconds + 15, 60)  # 最大60秒
                            print(f"      📈 增加超时时间: {old_timeout}秒 → {timeout_seconds}秒")
                            time.sleep(2 ** retry)
                        else:
                            print(f"      ❌ {acc} 下载超时，已达到最大重试次数")
                                
                    except Exception as e:
                        print(f"      ❌ 下载异常 (重试 {retry+1}/{max_retries}): {e}")
                        if "429" in str(e) or "rate" in str(e).lower():
                            print(f"      ⚠️  检测到频率限制，延长等待时间...")
                            time.sleep(5)  # 遇到频率限制时等待更长时间
                        if retry < max_retries - 1:
                            time.sleep(2 ** retry)
                        else:
                            print(f"      ❌ {acc} 下载失败，已达到最大重试次数")
                
                if not success:
                    total_failed += 1
            
            # 批次间暂停
            if batch_end < len(acc_ids):
                print(f"  ⏸️  批次完成，暂停 {get_request_interval() * 2:.1f} 秒...")
                time.sleep(get_request_interval() * 2)

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
    print(f"⏱️  请求间隔: {get_request_interval():.2f}秒 ({'有API密钥' if Entrez.api_key else '无API密钥'})")
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
