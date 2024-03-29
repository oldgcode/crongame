NAME=crongame
VERSION=trunk
CC = llvm-g++
CFLAGS = -O0 -g3 -pipe -ansi -Wabi
.if defined(BE_PEDANTIC)
CFLAGS += -pedantic
.endif
CFLAGS += -Weffc++ -fno-gnu-keywords -Wstrict-null-sentinel -Wctor-dtor-privacy -Wnon-virtual-dtor -Woverloaded-virtual -Wsign-promo -ffor-scope
CFLAGS += -Wall -Wextra
CFLAGS += -Wformat=2 -Wformat-y2k -Wformat-nonliteral -Wformat-security
CFLAGS += -Wunused -Wunused-parameter -Winit-self -Wmissing-include-dirs -Wfloat-equal
CFLAGS += -Wfloat-equal -Wundef -Wshadow -Wcast-qual -Wcast-align -fabi-version=0 -funroll-loops
CFLAGS += -Wunreachable-code -Winline
#CFLAGS += -pthread -isystem /usr/local/include/boost/ -isystem /usr/local/include
#LDFLAGS += -L/usr/local/lib -lboost_filesystem
ALLEGRO_FLAGS != allegro-config --cppflags
ALLEGRO_LINK_FLAGS != allegro-config --libs
INCLUDES = -I/usr/local/include -Iinclude/
CFLAGS += $(ALLEGRO_FLAGS) $(INCLUDES) #$(SDL_FLAGS)
LINK_FLAGS = -ladime $(ALLEGRO_LINK_FLAGS)
LDFLAGS += $(ALLEGRO_LINK_FLAGS)

SRCDIR = src
HDRDIR = include
TESTDIR = tests
SRCS != find $(SRCDIR) -name "*.cpp"
TSTSRCS = gerror.cpp
SCRIPTDIR = scripts
SCRIPTS != find $(SCRIPTDIR) -name "*.sh"
HDRS != find $(HDRDIR) -name "*.h"
OBJS= gamefield.o kernel.o brick.o krandom.o gerror.o mtimer.o ball.o paddle.o game.o power.o controls.o
TXTFILES = LICENSE
BUILDFILES = Makefile

ALLFILES = $(HDRS) $(SRCS) $(TXTFILES) $(BUILDFILES) $(SCRIPTS)

BINNAME = $(NAME)

.if defined(BRICK_NUM)
CFLAGS += -DBRICK_NUM=$(BRICK_NUM)
BINNAME = $(TESTDIR)/$(NAME)-bricktest-$(BRICK_NUM)
.endif

#compiling options
.PHONY:     all clean cleantests test test-all check doc version truebuild

all: version $(SRCDIR)/main.cpp
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) $(SRCDIR)/main.cpp -o $(BINNAME)
	
$(SRCDIR)/main.cpp: $(OBJS)
gamefield.o: $(HDRDIR)/gamefield.h $(HDRDIR)/common.h $(SRCDIR)/gamefield.cpp krandom.o brick.o power.o
kernel.o: $(HDRDIR)/kernel.h $(HDRDIR)/common.h $(SRCDIR)/kernel.cpp mtimer.o gamefield.o ball.o paddle.o game.o controls.o $(HDRDIR)/game_status_constants.h
brick.o: $(HDRDIR)/brick.h $(HDRDIR)/common.h $(SRCDIR)/brick.cpp $(HDRDIR)/power.h
krandom.o: $(HDRDIR)/krandom.h $(HDRDIR)/common.h $(SRCDIR)/krandom.cpp
gerror.o: $(HDRDIR)/gerror.h $(HDRDIR)/common.h $(SRCDIR)/gerror.cpp
mtimer.o: $(HDRDIR)/mtimer.h $(HDRDIR)/common.h $(SRCDIR)/mtimer.cpp
ball.o: $(HDRDIR)/ball.h $(HDRDIR)/common.h $(SRCDIR)/ball.cpp paddle.o $(HDRDIR)/power.h controls.o
paddle.o: $(HDRDIR)/paddle.h $(HDRDIR)/common.h $(SRCDIR)/paddle.cpp
game.o: $(HDRDIR)/game.h $(HDRDIR)/common.h $(SRCDIR)/game.cpp
power.o: $(HDRDIR)/paddle.h $(HDRDIR)/common.h $(SRCDIR)/power.cpp
controls.o: $(HDRDIR)/controls.h $(HDRDIR)/common.h $(SRCDIR)/controls.cpp
dialog.o: $(HDRDIR)/dialog.h $(HDRDIR)/common.h $(SRCDIR)/dialog.cpp

#.include "makefile.deps"

clean: cleantests
	rm -fv $(OBJS)
	rm -fv ./$(NAME)
	rm -rfvd doc/html/
	rm -rfvd doc/latex/
	rm -rfvd doc/man/           

cleantests:
	rm -fv $(TESTDIR)/*-test*
	rm -fv $(TESTDIR)/*-bricktest*

test:
	$(CC) -DTEST $(CFLAGS) $(LDFLAGS) $(SRCDIR)/$(FILE) -o $(TESTDIR)/$(FILE)-test

test-all:
	for file in $(TSTSRCS);do $(MAKE) test FILE=$$file; done;

check:
	cppcheck -v -a -s --unused-functions src/
	rats -rw3 src/*
	splint -strict-lib -showcolumn -showfunc -strict src/*.c
	flawfinder src/*.cpp

doc: version
	doxygen doc/doxygen-config 

version:
	@echo $(NAME) version $(VERSION)

#makedepend:
#	makedepend -I $(INCLUDES) -f makefile.deps -- $(CFLAGS) -- $(SRCS)

truebuild: version clean all

#	$(CC) $(CFLAGS) -c $< -o $@

.include "Depends.Makefile"