#!/usr/bin/env python3
import os
import sys
import time
import argparse
from typing import List, Optional, Tuple
from Bio import Entrez


def get_request_interval() -> float:
    """Return recommended delay between requests based on API key presence."""
    return 0.12 if Entrez.api_key else 0.4


LINK_MAP = {
    "genomic": ("gene_nuccore_refseqgenomic", "nuccore"),
    "mrna": ("gene_nuccore_refseqrna", "nuccore"),
    "protein": ("gene_protein_refseq", "protein"),
}


def read_ids_from_file(path: str) -> List[str]:
    gene_ids: List[str] = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            s = line.strip()
            if not s or s.startswith("#"):
                continue
            parts = [p for token in s.split() for p in token.split(",")]
            gene_ids.extend([p for p in parts if p])
    return gene_ids


def esummary_gene(gene_id: str):
    handle = Entrez.esummary(db="gene", id=gene_id, retmode="xml")
    data = Entrez.read(handle)
    handle.close()
    return data


def validate_gene_organism(gene_id: str, organism: str) -> Tuple[bool, Optional[str]]:
    try:
        data = esummary_gene(gene_id)
        doc = data[0] if data else {}
        organism_name: Optional[str] = None
        if isinstance(doc.get("Organism"), dict):
            organism_name = doc["Organism"].get("ScientificName") or doc["Organism"].get("CommonName")
        elif "NomenclatureOrganism" in doc:
            organism_name = doc.get("NomenclatureOrganism")
        if not organism_name:
            return False, None
        is_match = organism_name.lower() == organism.lower()
        return is_match, organism_name
    except Exception:
        return False, None


def elink_gene_to_target_ids(gene_id: str, linkname: str) -> List[str]:
    handle = Entrez.elink(dbfrom="gene", id=gene_id, linkname=linkname)
    record = Entrez.read(handle)
    handle.close()
    linksets = record[0].get("LinkSetDb", []) if record else []
    if not linksets:
        return []
    return [link["Id"] for link in linksets[0].get("Link", [])]


def efetch_fasta(db: str, ids: List[str]) -> str:
    if not ids:
        return ""
    handle = Entrez.efetch(db=db, id=",".join(ids), rettype="fasta", retmode="text")
    text = handle.read()
    handle.close()
    return text


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch NCBI FASTA by GeneID + Organism.")
    parser.add_argument("--email", required=True, help="你的邮箱（NCBI 要求）")
    parser.add_argument("--api-key", default=os.getenv("NCBI_API_KEY"), help="可选：NCBI API Key，或用环境变量 NCBI_API_KEY")
    parser.add_argument("--organism", required=True, help='物种科学名，例如 "Homo sapiens" 或 "Mus musculus"')
    parser.add_argument("--type", choices=["genomic", "mrna", "protein"], default="genomic", help="序列类型（默认 genomic）")
    parser.add_argument("--ids", help="逗号分隔的 GeneID 列表，例如 672,7157")
    parser.add_argument("--file", help="包含 GeneID 的文件，每行可为一个或多个以逗号/空白分隔的 GeneID")
    parser.add_argument("--out", default="sequences.fasta", help="输出 FASTA 文件名（默认 sequences.fasta）")
    parser.add_argument("--first", action="store_true", help="仅取每个 GeneID 的第一条关联序列")
    parser.add_argument("--longest", action="store_true", help="每个 GeneID 仅输出最长的一条序列（基于 FASTA 长度）")
    parser.add_argument("--skip-verify", action="store_true", help="跳过 GeneID 与物种匹配验证（默认会验证）")
    args = parser.parse_args()

    Entrez.email = args.email
    if args.api_key:
        Entrez.api_key = args.api_key

    if not args.ids and not args.file:
        print("必须提供 --ids 或 --file", file=sys.stderr)
        sys.exit(2)

    gene_ids: List[str] = []
    if args.ids:
        gene_ids.extend([i.strip() for i in args.ids.split(",") if i.strip()])
    if args.file:
        gene_ids.extend(read_ids_from_file(args.file))

    # 去重并保持顺序
    seen = set()
    dedup_ids: List[str] = []
    for gid in gene_ids:
        if gid not in seen:
            seen.add(gid)
            dedup_ids.append(gid)
    gene_ids = dedup_ids

    linkname, db = LINK_MAP[args.type]
    interval = get_request_interval()

    total_ok = 0
    total_warn = 0
    with open(args.out, "w", encoding="utf-8") as fout:
        for gid in gene_ids:
            try:
                if not args.skip_verify:
                    ok, real_org = validate_gene_organism(gid, args.organism)
                    time.sleep(interval)
                    if not ok:
                        total_warn += 1
                        print(f"[WARN] GeneID {gid} 物种不匹配或无法验证（实际: {real_org}）", file=sys.stderr)
                        continue

                target_ids = elink_gene_to_target_ids(gid, linkname)
                time.sleep(interval)
                if not target_ids:
                    total_warn += 1
                    print(f"[WARN] GeneID {gid} 未找到关联 {args.type} 序列", file=sys.stderr)
                    continue

                selected_ids = target_ids
                if args.first:
                    selected_ids = [target_ids[0]]
                elif args.longest:
                    fasta_all = efetch_fasta(db, target_ids)
                    time.sleep(interval)
                    entries = fasta_all.strip().split("\n>")
                    best_entry = ""
                    best_len = -1
                    for idx, entry in enumerate(entries):
                        if not entry.strip():
                            continue
                        if idx == 0 and not entry.startswith(">"):
                            entry = ">" + entry
                        lines = entry.splitlines()
                        seq = "".join(lines[1:]).replace(" ", "").replace("\r", "")
                        if len(seq) > best_len:
                            best_len = len(seq)
                            best_entry = entry
                    if best_entry:
                        if not best_entry.startswith(">"):
                            best_entry = ">" + best_entry
                        fout.write(best_entry.strip() + "\n")
                        total_ok += 1
                        print(f"[OK] GeneID {gid}: 选择最长条目，长度={best_len}")
                    else:
                        total_warn += 1
                        print(f"[WARN] GeneID {gid} 选择最长失败", file=sys.stderr)
                    continue

                fasta = efetch_fasta(db, selected_ids)
                time.sleep(interval)
                if fasta.strip():
                    fout.write(fasta if fasta.endswith("\n") else fasta + "\n")
                    total_ok += 1
                    print(f"[OK] GeneID {gid}: 输出 {args.type} {len(selected_ids)} 条")
                else:
                    total_warn += 1
                    print(f"[WARN] GeneID {gid} efetch 结果为空", file=sys.stderr)

            except Exception as e:
                total_warn += 1
                print(f"[ERR] GeneID {gid}: {e}", file=sys.stderr)

    print(f"完成：成功 {total_ok}，警告/失败 {total_warn}。输出文件：{args.out}")


if __name__ == "__main__":
    main()


