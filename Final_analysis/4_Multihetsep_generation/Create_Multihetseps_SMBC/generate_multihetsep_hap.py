#!/usr/bin/env python3

import sys
import gzip
import argparse
import io

class MaskIterator:
    def __init__(self, filename, negative=False):
        if filename[-3:] == ".gz":
            self.file = io.TextIOWrapper(gzip.open(filename, "r"))
        else:
            self.file = open(filename, "r")
        self.eof = False
        self.lastPos = 1
        self.negative = negative
        self.readLine()

    def readLine(self):
        try:
            line = next(self.file)
            fields = line.strip().split()
            if len(fields) == 2:
                self.start = int(fields[0])
                self.end = int(fields[1])
            else:
                self.start = int(fields[1]) + 1
                self.end = int(fields[2])
        except StopIteration:
            self.eof = True

    def getVal(self, pos):
        assert pos >= self.lastPos
        self.lastPos = pos
        while not self.eof and pos > self.end:
            self.readLine()
        if self.eof:
            return None
        if pos >= self.start and pos <= self.end:
            return True if not self.negative else False
        else:
            return False if not self.negative else True

class MergedMask:
    def __init__(self, mask_iterators):
        self.maskIterators = mask_iterators

    def getVal(self, pos):
        return all((m.getVal(pos) for m in self.maskIterators))


class VcfIterator:
    def __init__(self, filename, as_phased):
        # Open the VCF file, which is gzip-compressed, in read mode.
        # Use io.TextIOWrapper to handle the text data from the gzip stream.
        self.file = io.TextIOWrapper(gzip.open(filename, "r"))
        # Store the as_phased parameter to determine if the data should be treated as phased.
        self.as_phased = as_phased

    def __iter__(self):
        # Return the iterator object itself. This is required for the object to be used in a loop.
        return self

    def __next__(self):
        # Read the next line from the file.
        line = next(self.file)
        # Skip header lines that start with '#'.
        while line[0] == "#":
            try:
                # Continue to the next line if the current line is a header.
                line = next(self.file)
            except StopIteration:
                # If there are no more lines to read, return None to signal the end of iteration.
                return None
        # Split the line into fields based on whitespace.
        fields = line.strip().split()
        # Extract the chromosome identifier from the first field.
        chrom = fields[0]
        # Extract the position (as an integer) from the second field.
        pos = int(fields[1])
        # Initialize the alleles list with the reference allele from the fourth field.
        alleles = [fields[3]]
        # Add alternate alleles (if any) from the fifth field, which may contain multiple alleles separated by commas.
        for alt_a in fields[4].split(","):
            alleles.append(alt_a)
        # Change1: Extract only the first element of the genotype string for haploid data.
        # The genotype string is found in the tenth field (index 9), and we take only the first character.
        geno = fields[9][0]  # Read only the first allele for haploid data
        # Set phased to True, as haploid data is inherently phased.
        phased = True
        # Return a tuple containing the chromosome, position, alleles, genotype, and phased status.
        return (chrom, pos, tuple(alleles), int(geno), phased)
    
class OrderedAlleles:
    def __init__(self):
        # Initialize an empty list to store ordered alleles.
        self.ordered_alleles = []
    #Change 2
    def addGenotype(self, a1, phasing):
        # Check if the ordered_alleles list is empty.
        if len(self.ordered_alleles) == 0:
            # If empty, initialize it with a list containing the first allele.
            self.ordered_alleles = [[a1]]
        else:
            # If not empty, create a new list to store updated allele orders.
            new = []
            # Iterate over each existing list of alleles in ordered_alleles.
            for o in self.ordered_alleles:
                # Append the new allele (a1) to each list of alleles.
                new.append(o + [a1])
            # Update ordered_alleles with the new lists that include the new allele.
            self.ordered_alleles = new

    def getPrint(self, trios):
        return ','.join([''.join(o) for o in self.ordered_alleles])

def unique(list_of_lists):
    return list(set([tuple(l) for l in list_of_lists]))

class JoinedVcfIterator:
    def __init__(self, filenames, trios, as_phased):
        self.vcfIterators = [VcfIterator(f, as_phased) for f in filenames]
        self.current_lines = [next(v) for v in self.vcfIterators]
        self.trios = trios

    def __iter__(self):
        return self

    def __next__(self):
        minIndices = self.getMinIndices()
        chrom = self.current_lines[minIndices[0]][0]
        pos = self.current_lines[minIndices[0]][1]
        ref = self.current_lines[minIndices[0]][2][0]
        ordered_alleles = OrderedAlleles()

        for i, l in enumerate(self.current_lines):
            if i not in minIndices:
                ordered_alleles.addGenotype(ref, True)
            else:
                alleles, geno, phased = l[2:5]
                ordered_alleles.addGenotype(alleles[geno], phased)

            try:
                self.current_lines[i] = next(self.vcfIterators[i])
            except StopIteration:
                self.current_lines[i] = None

        return (chrom, pos, ordered_alleles.getPrint(self.trios))

    def getMinIndices(self):
        activeLines = [(i, l) for i, l in enumerate(self.current_lines) if l]
        if len(activeLines) == 0:
            raise StopIteration
        if len(activeLines) == 1:
            return [activeLines[0][0]]
        else:
            minIndices = [activeLines[0][0]]
            minPos = activeLines[0][1][1]
            for a in activeLines[1:]:
                if a[1][1] == minPos:
                    minIndices.append(a[0])
                if a[1][1] < minPos:
                    minPos = a[1][1]
                    minIndices = [a[0]]
            return minIndices

parser = argparse.ArgumentParser()
parser.add_argument("files", nargs="+", help="Input VCF files")
parser.add_argument("--mask", action="append", help="apply masks in bed format, should be given once for the calling mask from each individual, and in addition can be given for e.g. mappability or admixture masks. Mask can be gzipped, if indicated by .gz file ending.")
parser.add_argument("--negative_mask", action="append", help="same as mask, but interpreted as negative mask, so places where sites should be excluded")
parser.add_argument("--trio", action="append", help="declare trio-relationships. This should be a string with a format ,,, where the three fields are the indices of the samples in the trio. This option will automatically phase parental and maternal haplotypes where possible and remove the child VCF file from the resulting file. Can be given multiple times if you have multiple trios.")
parser.add_argument("--chr", help="overwrite chromosomes in input files. Useful if chromosome names differ, such as chr1 vs. 1")
parser.add_argument("--as_phased", action="store_true", help="considered unphased genotypes as phased. Saves resources when only pairs of haplotypes within individuals are considered.")

args = parser.parse_args()

trios = []
if args.trio:
    trios = [tuple(map(int, t.split(","))) for t in args.trio]

nrIndidividuals = len(args.files)
nrHaplotypes = nrIndidividuals  # For haploid data, number of haplotypes equals number of individuals

sys.stderr.write("generating msmc input file with {} haplotypes\n".format(nrHaplotypes))

as_phased = True  # Haploid data is always considered phased
sys.stderr.write("Genotypes considered as phased for haploid data.\n")

joinedVcfIterator = JoinedVcfIterator(args.files, trios, as_phased)

maskIterators = []
if args.mask:
    for f in args.mask:
        sys.stderr.write("adding mask: {}\n".format(f))
        maskIterators.append(MaskIterator(f))
if args.negative_mask:
    for nm in args.negative_mask:
        sys.stderr.write("adding negative mask: {}\n".format(nm))
        maskIterators.append(MaskIterator(nm, True))

mergedMask = MergedMask(maskIterators)

def is_segregating(alleles):
    orders = alleles.split(",")
    for o in orders:
        for a in o[1:]:
            if a != o[0]:
                return True
    return False

pos = 0
nr_called = 0

for chrom, snp_pos, alleles in joinedVcfIterator:
    while pos < snp_pos:
        pos += 1
        if mergedMask.getVal(pos):
            nr_called += 1
        if pos % 1000000 == 0:
            print("processing pos {}".format(pos), file=sys.stderr)
    if mergedMask.getVal(snp_pos):
        if is_segregating(alleles):
            c = chrom if not args.chr else args.chr
            print(c, snp_pos, nr_called, alleles, sep="\t")
            nr_called = 0
  
