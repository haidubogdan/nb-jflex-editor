/*
* JFLEX HIGHLIGHT
*/

package org.netbeans.modules.jflex.editor.lexer;

%%
%public
%class JflexColoringLexer
%type JflexTokenId
%function findNextToken
%unicode
%caseless
%char


%{
    protected void pushState(final int state) {
        stack.push(getZZLexicalState());
        yybegin(state);
    }

%}


%eofval{
        if(input.readLength() > 0) {
            String yytext = yytext();
            // backup eof
            input.backup(1);
            //and return the text as error token
             return JflexTokenId.T_JAVA;
        } else {
            return null;
        }
%eofval}

%state ST_JFLEX_DECL

WHITESPACE = [ \t\f]
INLINE_COMMENT = "//" + [^\n]+
REGEX_LABEL_DEFINITION = {LABEL} + {WHITESPACE}* + "="
%%

<YYINITIAL>{INLINE_COMMENT} {
   return JflexTokenId.T_JAVA; 
}

<YYINITIAL>"ss" {
   return JflexTokenId.T_JAVA; 
}

<YYINITIAL>[\s] {
   return JflexTokenId.T_JAVA; 
}