// A simple syntax-directed translator for a simple language

grammar MyLanguageV1Code;

// Root non-terminal symbol
// A program is a bunch of declarations followed by a bunch of statements
// The Java code outputs the necessary NASM code around these declarations

program
    :   {   System.out.println("%include \"asm_io.inc\"");
            System.out.println("\nsegment .bss");   }
        declaration*
        {   System.out.println("\nsegment .text");
            System.out.println("\tglobal\tasm_main");
            System.out.println("\nasm_main:");
            System.out.println("\tenter\t0, 0");
            System.out.println("\tpusha");   }
        statement*
        {   System.out.println("\tpopa");
            System.out.println("\tmov\teax, 0");
            System.out.println("\tleave");
            System.out.println("\tret");   }
    ;

// Parse rule for variable declarations

declaration
    :   {   int a;   }
        INT a=NAME
        {   System.out.println("\t" + $a.text + "\tresd 1");   }
        (   COMMA
            a=NAME
            {   System.out.println("\t" + $a.text + "\tresd 1");   }
        )*
        SEMICOLON
    ;

// Parse rule for statements

statement
    :   ifstmt
    |   printstmt
    |   assignstmt
    ;

// Parse rule for if statements

ifstmt
    :   {   int a, b;   }
        {   String label;   }
        IF LPAREN a=identifier EQUAL b=integer RPAREN
        {   System.out.println("\tcmp\tdword " + $a.toString + ", " + $b.toString);
            label = "label_" + Integer.toString($IF.index);
            System.out.println("\tjnz\t" + label);   }
        statement*
        (   ELSE
            {   label = "label_" + Integer.toString($ELSE.index);
                System.out.println("\tjmp\t" + label);
                label = "label_" + Integer.toString($IF.index);
                System.out.println("\n" + label + ":");   }
            statement*
            {   label = "label_" + Integer.toString($ELSE.index);   }
        )?
        {   System.out.println("\n" + label + ":");   }
        ENDIF
    ;

// Parse rule for print statements

printstmt
    :   PRINT term SEMICOLON
        {   System.out.println("\tmov\teax, " + $term.toString);
            System.out.println("\tcall\tprint_int");
            System.out.println("\tcall\tprint_nl");   }
    ;

// Parse rule for assignment statements

assignstmt
    :   {   int a;   }
        a=NAME ASSIGN expression SEMICOLON
        {   System.out.println("\tmov\t[" + $a.text + "], eax");   }
    ;

// Parse rule for expressions

expression
    :   {   int a, b;   }
        a=term
        {   System.out.println("\tmov\teax, " + $a.toString);   }
    |   a=term
        {   System.out.println("\tmov\teax, " + $a.toString);   }
        (   PLUS b=term
            {   System.out.println("\tadd\teax, " + $b.toString);   }
        )?
        (   MINUS b=term
            {   System.out.println("\tsub\teax, " + $b.toString);   }
        )?
    ;

// Parse rule for terms

term returns [String toString]
    :   identifier {    $toString = $identifier.toString;   }
    |   integer {   $toString = $integer.toString;   }
    ;

// Parse rule for identifiers

identifier returns [String toString]
    :   NAME
        {   $toString = "[" +   $NAME.text  +   "]";   }
    ;

// Parse rule for numbers

integer returns [String toString]
    :   INTEGER
        {   $toString = $INTEGER.text;   }
    ;


// Reserved Keywords
////////////////////////////////

IF: 'if';
ELSE: 'else';
ENDIF: 'endif';
PRINT: 'print';
INT: 'int';

// Operators
PLUS: '+';
MINUS: '-';
EQUAL: '==';
ASSIGN: '=';
NOTEQUAL: '!=';

// Semicolon and parentheses
SEMICOLON: ';';
COMMA: ',';
LPAREN: '(';
RPAREN: ')';

// Integers
INTEGER: [0-9][0-9]*;

// Variable names
NAME: [a-z]+;

// Ignore all white spaces
WS: [ \t\r\n]+ -> skip;
