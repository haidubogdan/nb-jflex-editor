   /*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright 2016 Oracle and/or its affiliates. All rights reserved.
 *
 * Oracle and Java are registered trademarks of Oracle and/or its affiliates.
 * Other names may be trademarks of their respective owners.
 *
 * The contents of this file are subject to the terms of either the GNU
 * General Public License Version 2 only ("GPL") or the Common
 * Development and Distribution License("CDDL") (collectively, the
 * "License"). You may not use this file except in compliance with the
 * License. You can obtain a copy of the License at
 * http://www.netbeans.org/cddl-gplv2.html
 * or nbbuild/licenses/CDDL-GPL-2-CP. See the License for the
 * specific language governing permissions and limitations under the
 * License.  When distributing the software, include this License Header
 * Notice in each file and include the License file at
 * nbbuild/licenses/CDDL-GPL-2-CP.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the GPL Version 2 section of the License file that
 * accompanied this code. If applicable, add the following below the
 * License Header, with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted [year] [name of copyright owner]"
 *
 * If you wish your version of this file to be governed by only the CDDL
 * or only the GPL Version 2, indicate your decision by adding
 * "[Contributor] elects to include this software in this distribution
 * under the [CDDL or GPL Version 2] license." If you do not indicate a
 * single choice of license, a recipient has the option to distribute
 * your version of this file under either the CDDL, the GPL Version 2 or
 * to extend the choice of license to its licensees as provided above.
 * However, if you add GPL Version 2 code and therefore, elected the GPL
 * Version 2 license, then the option applies only if the new code is
 * made subject to such option by the copyright holder.
 *
 * Contributor(s):
 *
 * Portions Copyrighted 2016 Sun Microsystems, Inc.
 */

package org.netbeans.modules.jflex.editor.lexer;

import org.netbeans.spi.lexer.LexerInput;
import org.netbeans.spi.lexer.LexerRestartInfo;
import org.netbeans.modules.jflex.editor.common.ByteStack;

@org.netbeans.api.annotations.common.SuppressWarnings({"SF_SWITCH_FALLTHROUGH", "URF_UNREAD_FIELD", "DLS_DEAD_LOCAL_STORE", "DM_DEFAULT_ENCODING", "EI_EXPOSE_REP"})
%%
%public
%class JflexColoringLexer
%type JflexTokenId
%function findNextToken
%unicode
%caseless
%char


%{
    private ByteStack stack = new ByteStack();
    private LexerInput input;
    private int pushBackCount = 0;
    private int curlyBalance = 0;
    private int curlyBalanceExpr = 0;
    private boolean hasExpression = false;
    private boolean inExpression = false;
    private boolean inRulesGroup = false;
    private String expression; 

    public JflexColoringLexer(LexerRestartInfo info) {
        this.input = info.input();
        if(info.state() != null) {
            //reset state
            setState((LexerState) info.state());
        } else {
            //initial state
            stack.push(YYINITIAL);
            zzState = YYINITIAL;
            zzLexicalState = YYINITIAL;
        }

    }

    public static final class LexerState  {
        final ByteStack stack;
        /** the current state of the DFA */
        final int zzState;
        /** the current lexical state */
        final int zzLexicalState;

        LexerState(ByteStack stack, int zzState, int zzLexicalState) {
            this.stack = stack;
            this.zzState = zzState;
            this.zzLexicalState = zzLexicalState;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null || obj.getClass() != this.getClass()) {
                return false;
            }
            LexerState state = (LexerState) obj;
            return (this.stack.equals(state.stack)
                && (this.zzState == state.zzState)
                );
        }

        @Override
        public int hashCode() {
            int hash = 11;
            hash = 31 * hash + this.zzState;
            hash = 31 * hash + this.zzLexicalState;
            if (stack != null) {
                hash = 31 * hash + this.stack.hashCode();
            }
            return hash;
        }
    }

    public LexerState getState() {
        return new LexerState(stack.copyOf(), zzState, zzLexicalState);
    }

    public void setState(LexerState state) {
        this.stack.copyFrom(state.stack);
        this.zzState = state.zzState;
        this.zzLexicalState = state.zzLexicalState;
    }

    protected int getZZLexicalState() {
        return zzLexicalState;
    }

    //other functions

    protected void pushBack(int i) {
        yypushback(i);
    }

    protected void popState() {
        yybegin(stack.pop());
    }

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
             return JflexTokenId.T_UNKNOWN;
        } else {
            return null;
        }
%eofval}

%state ST_JFLEX_OPTIONS_AND_DECLARATIONS
%state ST_JFLEX_LOOKING_FOR_OPTION_PARAM
%state ST_JFLEX_LOOKING_FOR_MACRO_DEFINITION
%state ST_JFLEX_MACRO_DEFINITION
%state ST_JFLEX_STATE_LEXICAL_RULE
%state ST_JFLEX_STATE_RULE_CONDITION
%state ST_JFLEX_STATE_LEXICAL_RULE_GROUP
%state ST_JFLEX_STATE_LEXICAL_RULE_LIST
%state ST_JFLEX_STATE_LEXICAL_RULE_CODE
%state ST_JFLEX_LOOKING_FOR_RULE_CODE
%state ST_JFLEX_TAG
%state ST_JFLEX_STATE_DEFINE
%state ST_JFLEX_REGEX_DEFINE
%state ST_JFLEX_LEXER_USERCODE
%state ST_JFLEX_CODEVAL_OPTION
%state ST_JFLEX_LEXICAL_RULES
%state ST_JFLEX_LOOKING_FOR_LABEL

LABEL=([[:letter:]_]|[\u007f-\u00ff])([[:letter:][:digit:]_]|[\u007f-\u00ff])*
OPTION = "%" + {LABEL}
NEWLINE = [\n]
WHITESPACE = [ \t\f]
LEXICAL_STATE_TAGS = "<" + {LABEL} + ("," + {WHITESPACE}* + {LABEL})* + ">" | "<<EOF>>"
REGEX_QUANTIFIER = "{" + ([0-9])+ "}"
REGEX_EXPRESSION = ("[" + ([^\[\n] | "^")+ "]" +  {REGEX_QUANTIFIER}?)+ ("|" + {WHITESPACE}* {STRING})* | ([\\] [\\]* [^\n] [\|]*)+
OTHER_EXPRESSION = [0-9] | [\\][a-z] | [a-z][\?] | ";"
REGEX_BLOCK = "[" ([^\[\n\"]+ | {REGEX_EXPRESSION})+ "]"
EOF = "<<EOF>>"
MACRO = "{" + {LABEL} + "}"
ANY_CHAR=[^]
INLINE_STRING = \"([^\n\\\"]|\\.)*\"
STRING = \"([^\\\"]|\\.)*\"
//comment
BLOCK_COMMENT = "/*" [*]* [^*] ~"*/" | "/*" "*"+ "/"
INLINE_COMMENT = "//" + [^\n]+
COMMENT = {BLOCK_COMMENT} | {INLINE_COMMENT}
MACRO_DEFINITION = {LABEL}
STANDARD_DIRECTIVE = "%" ("init" | "initthrow" | "eofval" | "eof" | "eofthrow")
OPERATOR = "[" | "]" | "(" | ")" | "{" | "}" | "*" | ":" | "|" | "-" | "+" | "%" | "." | "?" | "!" | "~" | "^" | "_" | "/"
//CONSTANT_LABEL = ([A-Z\_] | [A-Z0-9\_])+
%%

<YYINITIAL>[^%]+ {
    //until the first "%" we are treating the code as JAVA
    return JflexTokenId.T_JAVA;
}

<YYINITIAL>"%%" {
    pushState(ST_JFLEX_OPTIONS_AND_DECLARATIONS);
    return JflexTokenId.T_JFLEX_DECL_WRAPPER_TAG;
}

/*
* OPTIONS AND DECLARATION
*/

<ST_JFLEX_OPTIONS_AND_DECLARATIONS>{COMMENT} {
    return  JflexTokenId.T_COMMENT;
}

<ST_JFLEX_OPTIONS_AND_DECLARATIONS>{NEWLINE}+ {
    return JflexTokenId.T_NEWLINE;
}
//USER CODE

<ST_JFLEX_OPTIONS_AND_DECLARATIONS>"%{" {
    pushState(ST_JFLEX_LEXER_USERCODE);
    return JflexTokenId.T_JFLEX_CLASS_CODE_TAG;
}

<ST_JFLEX_OPTIONS_AND_DECLARATIONS>"%}" {
    return JflexTokenId.T_JFLEX_CLASS_CODE_TAG;
}


<ST_JFLEX_LEXER_USERCODE> ~ "%}" {
    popState();
    yypushback(2);
    return JflexTokenId.T_JAVA;
}

<ST_JFLEX_OPTIONS_AND_DECLARATIONS>{STANDARD_DIRECTIVE} "{" {
    pushState(ST_JFLEX_CODEVAL_OPTION);
    return JflexTokenId.T_JFLEX_CLASS_CODE_TAG;
}

<ST_JFLEX_CODEVAL_OPTION>[^%]+ ~ {STANDARD_DIRECTIVE} "}" {
    String tt = yytext();
    int directiveNameIndex = tt.lastIndexOf("%");
    yypushback(tt.length() - directiveNameIndex);
    return JflexTokenId.T_JAVA;
}

<ST_JFLEX_CODEVAL_OPTION>{STANDARD_DIRECTIVE} "}" {
    popState();
    return JflexTokenId.T_JFLEX_CLASS_CODE_TAG;
}

<ST_JFLEX_CODEVAL_OPTION>"%" {
    //just a ordinary char
    return JflexTokenId.T_JAVA;
}

// simple option

<ST_JFLEX_OPTIONS_AND_DECLARATIONS>{OPTION} {
    pushState(ST_JFLEX_LOOKING_FOR_OPTION_PARAM);
    return JflexTokenId.T_JFLEX_OPTION;
}

<ST_JFLEX_LOOKING_FOR_OPTION_PARAM, ST_JFLEX_LOOKING_FOR_MACRO_DEFINITION>{WHITESPACE}+ {
    return JflexTokenId.T_WHITESPACE;
}

<ST_JFLEX_LOOKING_FOR_OPTION_PARAM>{LABEL} {
    return JflexTokenId.T_KEYWORD;
}

<ST_JFLEX_LOOKING_FOR_OPTION_PARAM>{NEWLINE} {
    popState();
    return JflexTokenId.T_NEWLINE;
}

//MACROS

<ST_JFLEX_OPTIONS_AND_DECLARATIONS> {
    {WHITESPACE}+ {
        return JflexTokenId.T_WHITESPACE;
    }
    {MACRO_DEFINITION} {
        pushState(ST_JFLEX_LOOKING_FOR_MACRO_DEFINITION);
        return JflexTokenId.T_JFLEX_MACRO;
    }
}

<ST_JFLEX_LOOKING_FOR_MACRO_DEFINITION>"=" {
    pushState(ST_JFLEX_MACRO_DEFINITION);
    return JflexTokenId.T_OPERATOR;
}

<ST_JFLEX_MACRO_DEFINITION> {
    {REGEX_EXPRESSION} | {REGEX_BLOCK} {
        return JflexTokenId.T_JFLEX_REGEX_EXPRESSION;
    }

    {MACRO} {
        return JflexTokenId.T_JFLEX_MACRO;
    }

    {INLINE_STRING} {
        return JflexTokenId.T_STRING;
    }

    {OPERATOR} {
        return JflexTokenId.T_OPERATOR;
    }

    {EOF} {
        return JflexTokenId.T_KEYWORD;
    }

    {OTHER_EXPRESSION} {
        return JflexTokenId.T_KEYWORD;
    }

    {WHITESPACE}+ {
        return JflexTokenId.T_WHITESPACE;
    }
}

<ST_JFLEX_MACRO_DEFINITION>{NEWLINE} {
    popState();
    popState();
    return JflexTokenId.T_NEWLINE;
}

<ST_JFLEX_OPTIONS_AND_DECLARATIONS>"%%" {
    pushState(ST_JFLEX_LEXICAL_RULES);
    return JflexTokenId.T_JFLEX_DECL_WRAPPER_TAG;
}

<ST_JFLEX_LEXICAL_RULES>{COMMENT} {
    return  JflexTokenId.T_COMMENT;
}

<ST_JFLEX_LEXICAL_RULES> {
    {WHITESPACE}+ {
        return JflexTokenId.T_WHITESPACE;
    }
    {NEWLINE}+ {
        return JflexTokenId.T_NEWLINE;
    }
}

<ST_JFLEX_LEXICAL_RULES>{LEXICAL_STATE_TAGS}{WHITESPACE}+ "{" ([\n] | [ ]) {
    int spaceCount = 0;
    for (char c : yytext().toCharArray()) {
        if (c == ' ') {
             spaceCount++;
        }
    }
    pushState(ST_JFLEX_STATE_LEXICAL_RULE_GROUP);
    yypushback(spaceCount + 2);
    inRulesGroup = true;
    return JflexTokenId.T_JFLEX_LEXICAL_STATE_TAG;
}

<ST_JFLEX_STATE_LEXICAL_RULE_GROUP>{
    {COMMENT} {
        return  JflexTokenId.T_COMMENT;
    }
    {WHITESPACE}+ {
        return JflexTokenId.T_WHITESPACE;
    }
    {NEWLINE}+ {
        return JflexTokenId.T_NEWLINE;
    }
}

<ST_JFLEX_STATE_LEXICAL_RULE_GROUP>"{" {
    pushState(ST_JFLEX_STATE_LEXICAL_RULE_LIST);
    return JflexTokenId.T_CURLY_OPEN;
}

<ST_JFLEX_STATE_LEXICAL_RULE_LIST> {
    {COMMENT} {
        return  JflexTokenId.T_COMMENT;
    }
    {REGEX_EXPRESSION} | {REGEX_BLOCK} | "." {
        return JflexTokenId.T_JFLEX_REGEX_EXPRESSION;
    }

    {MACRO} {
        return JflexTokenId.T_JFLEX_MACRO;
    }

    {INLINE_STRING} {
        return JflexTokenId.T_STRING;
    }
    {WHITESPACE}+ {
        return JflexTokenId.T_WHITESPACE;
    }
    {NEWLINE}+ {
        return JflexTokenId.T_NEWLINE;
    }
}

<ST_JFLEX_STATE_LEXICAL_RULE_LIST>"{" {
    curlyBalanceExpr = 1;
    pushState(ST_JFLEX_STATE_LEXICAL_RULE_CODE);
    return JflexTokenId.T_CURLY_OPEN;
}


<ST_JFLEX_STATE_LEXICAL_RULE_LIST>"}" {
    pushState(ST_JFLEX_LEXICAL_RULES);
    inRulesGroup = false;
    return JflexTokenId.T_CURLY_CLOSE;
}

<ST_JFLEX_STATE_LEXICAL_RULE_LIST>{OPERATOR} {
    return JflexTokenId.T_OPERATOR;
}

<ST_JFLEX_LEXICAL_RULES>{LEXICAL_STATE_TAGS} {
    pushState(ST_JFLEX_STATE_RULE_CONDITION);
    return JflexTokenId.T_JFLEX_LEXICAL_STATE_TAG;
}

<ST_JFLEX_STATE_RULE_CONDITION>
 {
    {REGEX_EXPRESSION} | {REGEX_BLOCK} | "."  {
        return JflexTokenId.T_JFLEX_REGEX_EXPRESSION;
    }

    {MACRO} {
        return JflexTokenId.T_JFLEX_MACRO;
    }

    {INLINE_STRING} {
        return JflexTokenId.T_STRING;
    }

    {EOF} {
        return JflexTokenId.T_KEYWORD;
    }

    {OTHER_EXPRESSION} {
        return JflexTokenId.T_KEYWORD;
    }

    {WHITESPACE}+ {
        return JflexTokenId.T_WHITESPACE;
    }
    {NEWLINE}+ {
        return JflexTokenId.T_NEWLINE;
    }
}

<ST_JFLEX_STATE_RULE_CONDITION>"{" {
    curlyBalanceExpr++;
    pushState(ST_JFLEX_STATE_LEXICAL_RULE_CODE);
    if (curlyBalanceExpr == 1) {
        return JflexTokenId.T_CURLY_OPEN;
    } else {
        return JflexTokenId.T_OTHER;
    }
}

<ST_JFLEX_STATE_RULE_CONDITION>{OPERATOR} {
    return JflexTokenId.T_OPERATOR;
}

/*
* RULE CODE
*/

<ST_JFLEX_STATE_LEXICAL_RULE_CODE>{COMMENT} {
    return JflexTokenId.T_JAVA;
}

<ST_JFLEX_STATE_LEXICAL_RULE_CODE>"'{'" | "'}'" {
    return JflexTokenId.T_JAVA;
}

<ST_JFLEX_STATE_LEXICAL_RULE_CODE>"{" {
    curlyBalanceExpr++;
    return JflexTokenId.T_JAVA;
}

<ST_JFLEX_STATE_LEXICAL_RULE_CODE>[^{}/*']+ {
    return JflexTokenId.T_JAVA;
}

<ST_JFLEX_STATE_LEXICAL_RULE_CODE>"*" | "'" {
    return JflexTokenId.T_OTHER;
}

<ST_JFLEX_STATE_LEXICAL_RULE_CODE>"}" {
    curlyBalanceExpr--;
    if(curlyBalanceExpr ==0){
        if (inRulesGroup){
            pushState(ST_JFLEX_STATE_LEXICAL_RULE_LIST);
        } else {
            pushState(ST_JFLEX_LEXICAL_RULES);
        }
        return JflexTokenId.T_CURLY_CLOSE;
    }
    return JflexTokenId.T_OTHER;
}

<ST_JFLEX_LEXICAL_RULES, ST_JFLEX_STATE_RULE_CONDITION, ST_JFLEX_STATE_LEXICAL_RULE_LIST, ST_JFLEX_STATE_LEXICAL_RULE_CODE, ST_JFLEX_STATE_LEXICAL_RULE_GROUP>{ANY_CHAR} {
    return  JflexTokenId.T_UNKNOWN;
}

<ST_JFLEX_CODEVAL_OPTION, ST_JFLEX_LEXER_USERCODE, ST_JFLEX_OPTIONS_AND_DECLARATIONS, ST_JFLEX_LOOKING_FOR_OPTION_PARAM, ST_JFLEX_LOOKING_FOR_MACRO_DEFINITION, ST_JFLEX_MACRO_DEFINITION>{ANY_CHAR} {
    return  JflexTokenId.T_UNKNOWN;
}

<YYINITIAL>{ANY_CHAR} {
    return  JflexTokenId.T_UNKNOWN;
}

<YYINITIAL, ST_JFLEX_LEXICAL_RULES><<EOF>> {
    if (input.readLength() > 0) {
          input.backup(1);  // backup eof
          return JflexTokenId.T_OTHER;
      }
      else {
          return null;
      }
}

<YYINITIAL>. {
   return JflexTokenId.T_UNKNOWN;
}