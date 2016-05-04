PREFIX ?= /usr
FLAGS ?= -pg

dgitprompt:
	dub build --compiler=ldc2 --build=release

cdeps: source/c/git.di source/app.d

source/app.d: src/temple/*.emd
	touch $@

source/c/git.di: source/c/git.o
	touch $@

source/c/git.o: source/c/git.c
	gcc  -Wall ${FLAGS} -c $< -o $@

install: dgitprompt
	install dgitprompt ${PREFIX}/bin/dgitprompt
