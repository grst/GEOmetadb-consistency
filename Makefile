INPUT= $(shell find . -maxdepth 1 -type f -name "*.Rmd")
HTML_FILES= $(patsubst %.Rmd,%.html,$(INPUT))

all: $(HTML_FILES)

%.html: %.Rmd
	Rscript -e "rmarkdown::render('$<', output_format='all')"
