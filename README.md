# Modificaiton by Nadeem Riaz
^-- slight code tweaks to update to facets 0.3
^-- add code to run HRD Scores

# FACETS.app

Wrapper script which takes a tumor/normal BAM pair then

* counts the base coverage over SNPs

* creates a join tumor/normal counts file

* runs facets

usage::
```bash
    ./FACETS.app/run.sh NORMAL.BAM TUMOR.BAM
```

