build_dir = build
elm_dir = src
static_dir = docs

build = ./build.sh


prod:
	$(build) -O -b $(build_dir) -o $(static_dir)

dev:
	$(build) -b $(build_dir) -o $(static_dir)

all:
	$(build) -O -b $(build_dir) -o $(static_dir)
