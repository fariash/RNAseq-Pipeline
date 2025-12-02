#!/usr/bin/env python3
import argparse
import pandas as pd

def main():
    parser = argparse.ArgumentParser(description="Concatenate VERSE exon count files into a single matrix")
    parser.add_argument("-i", "--inputs", nargs="+", required=True, help="List of VERSE exon.txt files")
    parser.add_argument("-o", "--output", required=True, help="Output CSV/TSV file")
    args = parser.parse_args()

    dfs = []
    for f in args.inputs:
        sample = f.split(".")[0] 
        df = pd.read_csv(f, sep="\t", header=None, names=["gene", sample])
        dfs.append(df.set_index("gene"))

    merged = pd.concat(dfs, axis=1)
    merged.to_csv(args.output, sep="\t")

if __name__ == "__main__":
    main()
