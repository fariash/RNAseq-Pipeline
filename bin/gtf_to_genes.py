#!/usr/bin/env python3
import argparse

parser = argparse.ArgumentParser(description="Extract gene_id and gene_name from a GTF file")
parser.add_argument("-i", "--input", dest="gtf", help="Input GTF file", required=True)
parser.add_argument("-o", "--output", dest="output", help="Output text file", required=True)
args = parser.parse_args()

gene_map = {}

with open(args.gtf, "r") as gtf_file:
    for line in gtf_file:
        if line.startswith("#"):
            continue

        fields = line.strip().split("\t")
        if len(fields) < 9:
            continue

        feature_type = fields[2]
        if feature_type != "gene":
            continue

        attributes = fields[8].split(";")
        attr_dict = {}
        for attr in attributes:
            attr = attr.strip()
            if not attr:
                continue
            try:
                key, value = attr.split(" ", 1)
                attr_dict[key] = value.strip('"')
            except ValueError:
                continue

        gene_id = attr_dict.get("gene_id")
        gene_name = attr_dict.get("gene_name")

        if gene_id and gene_name:
            gene_map[gene_id] = gene_name

# Write output
with open(args.output, "w") as out:
    out.write("gene_id\tgene_name\n")
    for gid, gname in gene_map.items():
        out.write(f"{gid}\t{gname}\n")
