PREFIX ?= /usr

dgitprompt:
	dub build

cdeps: source/c/git.di source/app.d

source/app.d: src/temple/*.emd
	touch $@

source/c/git.di: source/c/git.o
	touch $@

source/c/git.o: source/c/git.c
	gcc -c $< -o $@

install: dgitprompt
	install dgitprompt ${PREFIX}/bin/dgitprompt
