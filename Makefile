build_dir = build
elm_dir = src
static_dir = docs
langs_dir = languages
tforms_dir = transforms

build = ./build.sh


site:
	$(build) -O -b $(build_dir) -o $(static_dir)

js:
	$(build) -b $(build_dir) -o $(static_dir)

all:
	$(build) -O -b $(build_dir) -o $(static_dir) -l $(langs_dir) -t $(tforms_dir)
