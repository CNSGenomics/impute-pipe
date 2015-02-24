# Cleans up the imputation directory, removing all files outputted by the 
# various scripts, including logs. Leaves reference and target data untouched.
rm -r data/*/chr*
rm -r data/qc/*
rm job_reports/* *.o* *.e* TEMP*
