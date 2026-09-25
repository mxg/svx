# SVX Library Class Catalogs — Makefile
#
# Regenerates the .tex sources from their Python generators and compiles PDFs.
# Requires: Python 3, pdflatex (TeX Live or MacTeX)
#
# Usage:
#   make              — regenerate all .tex files and build all PDFs
#   make src          — regenerate and build the src/ catalog only
#   make apps         — regenerate and build the apps/ catalog only
#   make examples     — regenerate and build the examples/ catalog only
#   make clean        — remove intermediate LaTeX files
#   make veryclean    — remove intermediate files and all PDFs

SRC_TEX      = svx_catalog_src
APPS_TEX     = svx_catalog_apps
EXAMPLES_TEX = svx_catalog_examples

GEN_SRC      = gen_catalog2.py
GEN_APPS     = gen_catalog_apps.py
GEN_EXAMPLES = gen_catalog_examples.py

.PHONY: all src apps examples clean veryclean

all: src apps examples

# Three passes: first for content, second for TOC/refs, third to resolve any
# remaining forward references (xltabular can need all three).

src: $(SRC_TEX).pdf

$(SRC_TEX).tex: $(GEN_SRC)
	python3 $(GEN_SRC)

$(SRC_TEX).pdf: $(SRC_TEX).tex
	pdflatex -interaction=nonstopmode $(SRC_TEX).tex
	pdflatex -interaction=nonstopmode $(SRC_TEX).tex
	pdflatex -interaction=nonstopmode $(SRC_TEX).tex

apps: $(APPS_TEX).pdf

$(APPS_TEX).tex: $(GEN_APPS)
	python3 $(GEN_APPS)

$(APPS_TEX).pdf: $(APPS_TEX).tex
	pdflatex -interaction=nonstopmode $(APPS_TEX).tex
	pdflatex -interaction=nonstopmode $(APPS_TEX).tex
	pdflatex -interaction=nonstopmode $(APPS_TEX).tex

examples: $(EXAMPLES_TEX).pdf

$(EXAMPLES_TEX).tex: $(GEN_EXAMPLES)
	python3 $(GEN_EXAMPLES)

$(EXAMPLES_TEX).pdf: $(EXAMPLES_TEX).tex
	pdflatex -interaction=nonstopmode $(EXAMPLES_TEX).tex
	pdflatex -interaction=nonstopmode $(EXAMPLES_TEX).tex
	pdflatex -interaction=nonstopmode $(EXAMPLES_TEX).tex

clean:
	rm -f $(SRC_TEX).aux      $(SRC_TEX).log      $(SRC_TEX).out      $(SRC_TEX).toc
	rm -f $(APPS_TEX).aux     $(APPS_TEX).log     $(APPS_TEX).out     $(APPS_TEX).toc
	rm -f $(EXAMPLES_TEX).aux $(EXAMPLES_TEX).log $(EXAMPLES_TEX).out $(EXAMPLES_TEX).toc

veryclean: clean
	rm -f $(SRC_TEX).pdf $(APPS_TEX).pdf $(EXAMPLES_TEX).pdf
