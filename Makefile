
site:
	./build.sh && cp build/main.min.js docs

dev:
	elm make src/Main.elm --output=docs/main.js
