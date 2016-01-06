zanol_riccardo.pdf: zanol_riccardo.tex .FORCE
	rm ./*.pdf || true
	pdflatex zanol_riccardo.tex
	pdflatex zanol_riccardo.tex

.PHONY: .FORCE
.FORCE: 
