# SVX Library Class Catalogs — Makefile
#
# Regenerates PDF catalogs from their LaTeX sources.
# Requires: pdflatex (TeX Live or MacTeX)
#
# Usage:
#   make              — build all catalogs
#   make src          — build the src/ catalog only
#   make apps         — build the apps/ catalog only
#   make clean        — remove intermediate files
#   make veryclean    — remove intermediate files and all PDFs

SRC_TEX  = svx_catalog_src
APPS_TEX = svx_catalog_apps

.PHONY: all src apps clean veryclean

all: src apps

# Three passes: first for content, second for TOC/refs, third to resolve any
# remaining forward references (xltabular can need all three).
src: $(SRC_TEX).pdf

$(SRC_TEX).pdf: $(SRC_TEX).tex
	pdflatex -interaction=nonstopmode $(SRC_TEX).tex
	pdflatex -interaction=nonstopmode $(SRC_TEX).tex
	pdflatex -interaction=nonstopmode $(SRC_TEX).tex

apps: $(APPS_TEX).pdf

$(APPS_TEX).pdf: $(APPS_TEX).tex
	pdflatex -interaction=nonstopmode $(APPS_TEX).tex
	pdflatex -interaction=nonstopmode $(APPS_TEX).tex
	pdflatex -interaction=nonstopmode $(APPS_TEX).tex

clean:
	rm -f $(SRC_TEX).aux  $(SRC_TEX).log  $(SRC_TEX).out  $(SRC_TEX).toc
	rm -f $(APPS_TEX).aux $(APPS_TEX).log $(APPS_TEX).out $(APPS_TEX).toc

veryclean: clean
	rm -f $(SRC_TEX).pdf $(APPS_TEX).pdf
