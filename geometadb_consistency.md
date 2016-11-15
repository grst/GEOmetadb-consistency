[GEOmetadb](https://www.bioconductor.org/packages/release/bioc/vignettes/GEOmetadb/inst/doc/GEOmetadb.html)
is a relational database containing meta information from the [Gene
Expression Omnibus (GEO)](https://www.ncbi.nlm.nih.gov/geo/). The
database is provided as SQLite database and is a wonderful ressource for
mining GEO for studies that are relevant for a certain project.

For one of my projects, I was loading the data into a postgreSQL server
and decided to add foreign key constraints in order to ensure
consistency of the data. Intrestingly, this failed for some relations,
due to the fact that the data from GEOmetadb is not consistent.

In this document, I check for these inconsistencies systematically.
Also, I acknowledge, that the inconsistencies are not necessarily the
fault of the authors of GEOmetadb, but can be an immanent property of
the messy data on GEO.

First, we establish a connection to the SQLite database.

    gdb = dbConnect(SQLite(), "GEOmetadb.sqlite")
    kable(dbGetQuery(gdb, "select * from metainfo"))

<table>
<thead>
<tr class="header">
<th align="left">name</th>
<th align="left">value</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">schema version</td>
<td align="left">1.0</td>
</tr>
<tr class="even">
<td align="left">creation timestamp</td>
<td align="left">2016-11-12 21:04:55</td>
</tr>
</tbody>
</table>

We define an SQL query, that will return all rows that violate the
foreign key constraint. Namely all rows in a table, where the
corresponding entry from the reference table does not exist.

    testForeignKey = function(table, col, ref_table, ref_col) {
      query = sprintf("select distinct %s
                           from %s
                           where not exists (
                               select * from %s
                               where %s.%s = %s.%s);", col, table, ref_table, table, col, ref_table, ref_col)
      res = dbGetQuery(gdb, query)
      return(nrow(res))
    }

We created a list of foreign keys in a csv file:

<table>
<thead>
<tr class="header">
<th align="left">table</th>
<th align="left">column</th>
<th align="left">references table</th>
<th align="left">on column</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">gse_gpl</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="left">gse</td>
</tr>
<tr class="even">
<td align="left">gse_gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
</tr>
<tr class="odd">
<td align="left">gse_gsm</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="left">gse</td>
</tr>
<tr class="even">
<td align="left">gse_gsm</td>
<td align="left">gsm</td>
<td align="left">gsm</td>
<td align="left">gsm</td>
</tr>
<tr class="odd">
<td align="left">gsm</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
</tr>
<tr class="even">
<td align="left">gsm</td>
<td align="left">gsm</td>
<td align="left">gse_gsm</td>
<td align="left">gsm</td>
</tr>
<tr class="odd">
<td align="left">sMatrix</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
</tr>
<tr class="even">
<td align="left">sMatrix</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="left">gse</td>
</tr>
<tr class="odd">
<td align="left">gds</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
</tr>
</tbody>
</table>

Now, we apply the test function to each of the foreign keys:

    diff = apply(fks, 1, function(vec) {testForeignKey(vec[1], vec[2], vec[3], vec[4])})
    tab = cbind(fks, diff)
    colnames(tab) = c(colnames(fks), "offending lines")
    kable(tab)

<table>
<thead>
<tr class="header">
<th align="left">table</th>
<th align="left">column</th>
<th align="left">references table</th>
<th align="left">on column</th>
<th align="right">offending lines</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">gse_gpl</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="right">0</td>
</tr>
<tr class="even">
<td align="left">gse_gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="right">0</td>
</tr>
<tr class="odd">
<td align="left">gse_gsm</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="right">0</td>
</tr>
<tr class="even">
<td align="left">gse_gsm</td>
<td align="left">gsm</td>
<td align="left">gsm</td>
<td align="left">gsm</td>
<td align="right">5865</td>
</tr>
<tr class="odd">
<td align="left">gsm</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="right">0</td>
</tr>
<tr class="even">
<td align="left">gsm</td>
<td align="left">gsm</td>
<td align="left">gse_gsm</td>
<td align="left">gsm</td>
<td align="right">44676</td>
</tr>
<tr class="odd">
<td align="left">sMatrix</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="right">145</td>
</tr>
<tr class="even">
<td align="left">sMatrix</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="left">gse</td>
<td align="right">50</td>
</tr>
<tr class="odd">
<td align="left">gds</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="left">gpl</td>
<td align="right">0</td>
</tr>
</tbody>
</table>

In particular, the `gsm` table does not contain all entries that are
referenced in `gse_gsm` and not all entries from `gsm` have a `gse`
associated. The latter could be the case if there were *Samples* in GEO,
that are not part of any *Series*.
