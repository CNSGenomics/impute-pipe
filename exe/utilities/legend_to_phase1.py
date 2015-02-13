"""
python 2.x

This script will convert the variant ID of the legend files provided by shapeit
phase3 release back to the same format as the phase1 release.

From https://mathgen.stats.ox.ac.uk/impute/impute_v2.html#reference 
https://mathgen.stats.ox.ac.uk/impute/1000GP Phase3 haplotypes 6 October 2014.html
"So that each variant has a unique ID we have edited the 
legend files so that the variant ID will be either rsID:position:ref:alt, 
or chr:position:ref:alt. If the site is a structural variant then the 
variant ID will be rsid:position:ref:alt:END or chrom:position:ref:alt:END 
where END is the endpoint of the variant."

Example:
> python convert_legend_format.py 1000GP_Phase3_chr${i}.legend > converted_1000GP_Phase3_chr${i}.legend
"""

from __future__ import print_function
import os
import sys 

lines = [line.strip() for line in open(sys.argv[1])]
for l in lines:
    data = l.split(' ')
    rd = data[0].split(':')
    #if the first column is a digit (chr) id is 'chr-pos'
    if rd[0].isdigit():
        new_id = rd[0]+'-'+rd[1]
    #else just use the rsid
    else:
        new_id = rd[0]

    print(new_id,data[1],data[2],data[3],data[4],data[5],data[6],data[7],data[8],data[9],data[10])

