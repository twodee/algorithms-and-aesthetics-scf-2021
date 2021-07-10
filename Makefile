# ---------------------------------------------------------------------------- 
# FILE:   Makefile                                                             
# AUTHOR: Chris Johnson                                                        
# DATE:   Apr 30 2007                                                          
#                                                                              
# This file generates a PDF from a LaTeX source file.
# ---------------------------------------------------------------------------- 

PDFLATEX = pdflatex
BIBTEX = bibtex
TEXFILES = $(wildcard *.tex)

MAINTEXFILE = main.tex

RERUN = "(There were undefined references|Rerun to get (cross-references|the bars) right)"
RERUNBIB = "No file.*\.bbl|Citation.*undefined" 

PDFS_FROM_SVGS = generated/crabfish.pdf generated/tetranet.pdf generated/perseverence.pdf generated/hex.pdf generated/d6.pdf generated/icerink.pdf generated/penrose.pdf
PNGS_FROM_SVGS = 
PNGFILES = $(wildcard images/*.png)
PDFFILES = $(MAINTEXFILE:.tex=.pdf)
BIBFILES = papers.bib
BBLFILES = $(MAINTEXFILE:.tex=.bbl)

COPY = if test -r $*.toc; then cp $*.toc $*.toc.bak; fi 
RM = rm -f 

all: pdf

pdf: $(PDFFILES)

$(BBLFILES): $(BIBFILES)
	@echo $@ $<
	@echo "Found BIB ($?) changed."
	@$(COPY); $(PDFLATEX) $(MAINTEXFILE)
	echo $(BIBTEX) $(MAINTEXFILE:.tex=) 

%.pdf: %.tex $(PDFS_FROM_SVGS) $(PNGS_FROM_SVGS) $(TEXFILES) $(BBLFILES)
	@echo "Found ($?) changed."
	@$(COPY); $(PDFLATEX) $<
	@egrep -c $(RERUNBIB) $*.log && ($(BIBTEX) $*; $(COPY); $(PDFLATEX) $<); true
	@egrep $(RERUN) $*.log && ($(COPY); $(PDFLATEX) $<); true
	@egrep $(RERUN) $*.log && ($(COPY); $(PDFLATEX) $<); true
	@if cmp -s $*.toc $*.toc.bak; then .; else $(PDFLATEX) $<; fi
	@$(RM) $*.toc.bak
	@egrep -i "(Reference|Citation).*undefined" $*.log ; true

$(PDFS_FROM_SVGS): generated/%.pdf: svgs/%.svg
	@echo "Found SVG ($?) changed."
	/Applications/Inkscape.app/Contents/MacOS/inkscape --export-area-page --export-filename=$@ $<

$(PNGS_FROM_SVGS): generated/%.png: svgs/%.svg
	@echo "Found SVG ($?) changed."
	/Applications/Inkscape.app/Contents/MacOS/inkscape --export-area-page --export-width=1000 --export-filename=$@ $<

%.run: $(PDFFILES)
	pdfonce $(PDFFILES) &

.PHONY: clean

FORCE:

clean:
	rm -rf $(PDFFILES) *.log *.bbl *.blg *.aux *.out generated
