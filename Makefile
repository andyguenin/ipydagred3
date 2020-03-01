testjs: ## Clean and Make js tests
	yarn test

testpy: ## Clean and Make unit tests
	python3.7 -m pytest -v ipydagred3/tests --cov=ipydagred3

tests: lint ## run the tests
	python3.7 -m pytest -v ipydagred3/tests --cov=ipydagred3 --junitxml=python_junit.xml --cov-report=xml --cov-branch
	yarn test

lint: ## run linter
	flake8 ipydagred3 
	yarn lint

fix:  ## run autopep8/tslint fix
	autopep8 --in-place -r -a -a ipydagred3/
	./node_modules/.bin/tslint --fix src/*

annotate: ## MyPy type annotation check
	mypy -s ipydagred3

annotate_l: ## MyPy type annotation check - count only
	mypy -s ipydagred3 | wc -l 

clean: ## clean the repository
	find . -name "__pycache__" | xargs  rm -rf 
	find . -name "*.pyc" | xargs rm -rf 
	find . -name ".ipynb_checkpoints" | xargs  rm -rf 
	rm -rf coverage lab-dist cover htmlcov logs build dist *.egg-info lib node_modules *.log
	git clean -fd
	make -C ./docs clean

docs:  ## make documentation
	make -C ./docs html
	open ./docs/_build/html/index.html

install:  ## install to site-packages
	pip3 install .

serverextension: install ## enable serverextension
	jupyter serverextension enable --py ipydagred3

js:  ## build javascript
	yarn
	yarn build

labextension: js ## enable labextension
	jupyter labextension install .

dist:  js  ## dist to pypi
	rm -rf dist build
	python3.7 setup.py sdist
	python3.7 setup.py bdist_wheel
	twine check dist/* && twine upload dist/*

# Thanks to Francoise at marmelab.com for this
.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'

.PHONY: clean install serverextension labextension test tests help docs dist