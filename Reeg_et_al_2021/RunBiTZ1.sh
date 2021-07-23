#!/bin/bash
cd ${PBS_O_WORKDIR}
R CMD BATCH ./RunBiTZ1.R ./outputfile1.Rout
