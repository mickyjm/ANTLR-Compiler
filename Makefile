CC=gcc
CFLAGS=-m32
ASM=nasm
ASMFLAGS=-f elf

ANTLR_JAR = ./antlr-4.7.1-complete.jar
ANTLR_FILE = MyLanguageV1Code
SOURCE_FILE = sourcecode.txt
NASM_PROGRAM=foo

default: 
	@echo "This is a makefile for the whole ANTLR toolchain"
	@echo "(assumes that $(ANTLR_JAR) is in this directory)"
	@echo 
	@echo "  - make compiler: create the compiler based on $(ANTLR_FILE).g4"
	@echo "  - make compile:  compile code in $(SOURCE_FILE)"
	@echo "  - make assemble: assemble the generated assembly in a $(NASM_PROGRAM) executable"
	@echo "  - make run:      compiler; compile; assemble; ./$(NASM_PROGRAM)"
	@echo "  - make clean:    clean up"
	@echo

run: compiler compile assemble
	./$(NASM_PROGRAM)

compiler: $(ANTLR_FILE).g4
	@echo "Creating compiler code based on $(ANTLR_FILE) file..."
	@java -jar $(ANTLR_JAR) $(ANTLR_FILE).g4
	@echo "Compiling compiler java code..."
	@javac  -cp .:$(ANTLR_JAR) *.java
	@echo "Compiler code generated!"

compile: compiler
	@echo "Compiling $(SOURCE_FILE) with our generated compiler"	
	@java  -cp .:$(ANTLR_JAR) org.antlr.v4.gui.TestRig $(ANTLR_FILE) program $(SOURCE_FILE) > $(NASM_PROGRAM).asm
	@echo "NASM program created in file $(NASM_PROGRAM).asm!"

assemble: compiler compile $(NASM_PROGRAM)
	@echo "NASM program assembled into executable $(NASM_PROGRAM)!"


$(NASM_PROGRAM): $(NASM_PROGRAM).o driver.o asm_io.o
	$(CC) $(CFLAGS) $(NASM_PROGRAM).o driver.o asm_io.o -o $(NASM_PROGRAM)

$(NASM_PROGRAM).o: $(NASM_PROGRAM).asm
	$(ASM) $(ASMFLAGS) $(NASM_PROGRAM).asm -o $(NASM_PROGRAM).o

asm_io.o: asm_io.asm
	$(ASM) $(ASMFLAGS) -d ELF_TYPE asm_io.asm -o asm_io.o

driver.o: driver.c
	$(CC) $(CFLAGS) -c driver.c -o driver.o

clean:
	/bin/rm -f *.java
	/bin/rm -f *.class
	/bin/rm -f *.tokens
	/bin/rm -f *.interp
	/bin/rm -f *.o
	/bin/rm -f $(NASM_PROGRAM)


