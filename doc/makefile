# SVX Library Catalogs — Makefile
#
# Builds the PDF catalogs from their LaTeX sources.  The .tex files are
# maintained by hand.
# Requires: pdflatex (TeX Live or MacTeX)
#
# Usage:
#   make              — build all PDFs
#   make src          — build the source code catalog (core library and
#                       UVM utilities)
#   make apps         — build the applications catalog
#   make examples     — build the examples catalog (core library and
#                       UVM utilities)
#   make clean        — remove intermediate LaTeX files
#   make veryclean    — remove intermediate files and all PDFs

SRC_TEX      = svx_catalog_src
APPS_TEX     = svx_catalog_apps
EXAMPLES_TEX = svx_catalog_examples

.PHONY: all src apps examples clean veryclean

all: src apps examples

src:      $(SRC_TEX).pdf
apps:     $(APPS_TEX).pdf
examples: $(EXAMPLES_TEX).pdf

# Three passes: first for content, second for TOC/refs, third to resolve any
# remaining forward references (xltabular can need all three).

%.pdf: %.tex
	pdflatex -interaction=nonstopmode $<
	pdflatex -interaction=nonstopmode $<
	pdflatex -interaction=nonstopmode $<

clean:
	rm -f $(SRC_TEX).aux      $(SRC_TEX).log      $(SRC_TEX).out      $(SRC_TEX).toc
	rm -f $(APPS_TEX).aux     $(APPS_TEX).log     $(APPS_TEX).out     $(APPS_TEX).toc
	rm -f $(EXAMPLES_TEX).aux $(EXAMPLES_TEX).log $(EXAMPLES_TEX).out $(EXAMPLES_TEX).toc

veryclean: clean
	rm -f $(SRC_TEX).pdf $(APPS_TEX).pdf $(EXAMPLES_TEX).pdf
