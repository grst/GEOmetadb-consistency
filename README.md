# GEOmetadb-consistency
*Checking GEOmetadb for consistency*

[GEOmetadb](https://www.bioconductor.org/packages/release/bioc/vignettes/GEOmetadb/inst/doc/GEOmetadb.html) is
a relational database containing meta information from the [Gene Expression Omnibus (GEO)](https://www.ncbi.nlm.nih.gov/geo/). The database is provided as SQLite database and is a wonderful ressource for mining GEO for studies that are relevant for a certain project. 

For one of my projects, I was loading the data into a postgreSQL server and decided to add foreign key constraints 
in order to ensure consistency of the data. Intrestingly, this failed for some relations, due to the fact that the data from GEOmetadb is not consistent. 

In [`geometadb_consistency.Rmd`](geometadb_consistency.md), I check for these inconsistencies systematically. Also, I acknowledge, that the inconsistencies are not necessarily the fault of the authors of GEOmetadb, but can be an immanent property of the messy data on GEO. 
