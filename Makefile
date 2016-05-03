.PHONY: all
## Execute all relevant rules
all: test documentation README.md

module_files = __init__.r cmd.r

.PHONY: test
## Run unit tests
test: ${module_files}
	Rscript __init__.r

.PHONY: documentation
## Build HTML documentation
documentation: cmdline_spec.html

cmdline_spec.html: ${module_files}

## Generate README from RMarkdown source
README.md: README.rmd ${module_files}
	Rscript -e 'knitr::knit("$<", "$@")'

%.html: %.rmd
	Rscript -e 'knitr::knit2html("$<")'

.DEFAULT_GOAL := show-help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n "/^## / { \
		h; \
		n; \
		s/:.*//; \
		G; \
		s/\\n## /---/; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$COLUMNS \
		-v indent=29 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more --no-init --raw-control-chars
