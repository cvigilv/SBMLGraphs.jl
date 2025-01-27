ENV=julia --project=.
FORMATTER=julia --project=@runic -e 'using Runic; exit(Runic.main(ARGS))' --

# .PHONY: setup venv lint format precommit test upload run clean help
.PHONY: setup repl format test clean help

help: ## Print this message
	@echo "usage: make [target] ..."
	@echo ""
	@echo "Available targets:"
	@grep --no-filename "##" $(MAKEFILE_LIST) | \
		grep --invert-match $$'\t' | \
		sed -e "s/\(.*\):.*## \(.*\)/ - \1:  \t\2/"

setup: ## Setup env
	julia --project=@SBMLGraphs_test -e "using Pkg; Pkg.add(path=\".\"); Pkg.add([\"SBML\", \"Graphs\"])"


repl: ## Run REPL with package installed as meant to be used
	julia --project=@SBMLGraphs_test

format: ## Format project codebase
	$(FORMATTER) --inplace .

test: ## Test project codebase covered in `tests/`
	$(ENV) -e "using Pkg; Pkg.test()"

clean: ## Remove environment
	rm -rf ~/.julia/environments/SBMLGraphs_test/
