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

%{
    private final List commentList = new ArrayList();
    private String heredoc = null;
    private int heredocBodyStart = -1;
    private int heredocBodyLength = 0;
    private final StringBuilder heredocBody = new StringBuilder();
    private String nowdoc = null;
    private int nowdoc_len  = 0;
    private int nowdocBodyStart = -1;
    private int nowdocBodyLength = 0;
    private final StringBuilder nowdocBody = new StringBuilder();
    private String comment = null;
    private boolean asp_tags = false;
    private boolean short_tags_allowed = true;
    private ByteStack stack = new ByteStack();
    private char yy_old_buffer[] = new char[ZZ_BUFFERSIZE];
    private int yy_old_pushbackPos;
    protected int commentStartPosition;
    private int whitespaceEndPosition;
    private boolean isEndedPhp;
    private final PHPDocCommentParser docParser = new PHPDocCommentParser();
    private final PHPVarCommentParser varParser = new PHPVarCommentParser();

    public ASTPHP5Scanner(java.io.Reader in, boolean short_tags_allowed, boolean asp_tags_allowed) {
        this(in);
        this.asp_tags = asp_tags_allowed;
        this.short_tags_allowed = short_tags_allowed;
    }
    //private AST ast;

    private int bracket = 0;

    /**
     * Returns balance beween '{' and '}'. If it's equesl 0,
     * then number of '{' == number of '}', if > 0 then '{' > '}' and
     * if return number < 0 then '{' < '}'
     */
    public int getCurlyBalance() {
        return bracket;
    }

    public int getWhitespaceEndPosition() {
        return whitespaceEndPosition;
    }

    public boolean isEndedPhp() {
        return isEndedPhp;
    }

    public boolean useAspTagsAsPhp() {
        return asp_tags;
    }

    public void reset(java.io.Reader reader) {
        yyreset(reader);
    }

    public void setState(int state) {
        yybegin(state);
    }

    public int getState() {
        return yystate();
    }

    public void setInScriptingState() {
        yybegin(ST_IN_SCRIPTING);
    }

    public void resetCommentList() {
        commentList.clear();
    }

    public List getCommentList() {
        return commentList;
    }

    protected void addComment(Comment.Type type) {
        int leftPosition = getTokenStartPosition();
        //System.out.println("#####AddCommnet start: " + commentStartPosition + " end: " + (leftPosition + getTokenLength()) + ", type: " + type);
        Comment comm;
        if (type == Comment.Type.TYPE_PHPDOC) {
            comm = docParser.parse(commentStartPosition, leftPosition + getTokenLength(),  comment);
            comment = null;
        }
        else if(type == Comment.Type.TYPE_VARTYPE) {
            comm = varParser.parse(commentStartPosition, leftPosition + getTokenLength(),  comment);
            comment = null;
            if (comm == null) {
                comm = new Comment(commentStartPosition, leftPosition + getTokenLength(), /*ast,*/ type);
            }
        }
        else {
            comm = new Comment(commentStartPosition, leftPosition + getTokenLength(), /*ast,*/ type);
        }
        commentList.add(comm);
    }

    public void setUseAspTagsAsPhp(boolean useAspTagsAsPhp) {
        asp_tags = useAspTagsAsPhp;
    }

    private void pushState(int state) {
        stack.push(zzLexicalState);
        yybegin(state);
    }

    private void popState() {
        yybegin(stack.pop());
    }

    public int getCurrentLine() {
        return yyline;
    }

    protected int getTokenStartPosition() {
        return zzStartRead - zzPushbackPos;
    }

    protected int getTokenLength() {
        return zzMarkedPos - zzStartRead;
    }

    public int getLength() {
        return zzEndRead - zzPushbackPos;
    }

    private void handleCommentStart() {
        commentStartPosition = getTokenStartPosition();
    }

    private void handleLineCommentEnd() {
        addComment(Comment.Type.TYPE_SINGLE_LINE);
    }

    private void handleMultilineCommentEnd() {
        addComment(Comment.Type.TYPE_MULTILINE);
    }

    private void handlePHPDocEnd() {
        addComment(Comment.Type.TYPE_PHPDOC);
    }

    private void handleVarComment() {
        commentStartPosition = getTokenStartPosition();
        addComment(Comment.Type.TYPE_VARTYPE);
    }

    private Symbol createFullSymbol(int symbolNumber) {
        Symbol symbol = createSymbol(symbolNumber);
        symbol.value = yytext();
        return symbol;
    }

    private Symbol createSymbol(int symbolNumber) {
        int leftPosition = getTokenStartPosition();
        Symbol symbol = new Symbol(symbolNumber, leftPosition, leftPosition + getTokenLength());
        return symbol;
    }

    private void updateNowdocBodyInfo() {
        if (nowdocBodyStart == -1) {
            nowdocBodyStart = getTokenStartPosition();
        }
        nowdocBody.append(yytext());
        nowdocBodyLength += getTokenLength();
    }

    private Symbol createFullNowdocBodySymbol() {
        Symbol symbol = new Symbol(ASTPHP5Symbols.T_ENCAPSED_AND_WHITESPACE, nowdocBodyStart, nowdocBodyStart + nowdocBodyLength);
        symbol.value = nowdocBody.toString();
        return symbol;
    }

    private void updateHeredocBodyInfo() {
        if (heredocBodyStart == -1) {
            heredocBodyStart = getTokenStartPosition();
        }
        heredocBody.append(yytext());
        heredocBodyLength += getTokenLength();
    }

    private void resetHeredocBodyInfo() {
        heredocBodyStart = -1;
        heredocBodyLength = 0;
        heredocBody.delete(0, heredocBody.length());
    }

    private Symbol createFullHeredocBodySymbol() {
        Symbol symbol = new Symbol(ASTPHP5Symbols.T_ENCAPSED_AND_WHITESPACE, heredocBodyStart, heredocBodyStart + heredocBodyLength);
        symbol.value = heredocBody.toString();
        resetHeredocBodyInfo();
        return symbol;
    }

    private boolean isLabelChar(char c) {
        return c == '_'
                || (c >= 'a' && c <= 'z')
                || (c >= 'A' && c <= 'Z')
                || (c >= 0x7f && c <= 0xff);
    }

    private boolean isEndHereOrNowdoc(String hereOrNowdoc) {
        // check whether ID exists
        String trimedText = yytext().trim();
        boolean isEnd = false;
        if (trimedText.startsWith(hereOrNowdoc)) {
            if (trimedText.length() == hereOrNowdoc.length()) {
                isEnd = true;
            } else if (trimedText.length() > hereOrNowdoc.length()
                    && !isLabelChar(trimedText.charAt(hereOrNowdoc.length()))) {
                // e.g.
                // $test = <<< END
                // ENDING
                // END
                isEnd = true;
            }
        }
        return isEnd;
    }

    public int[] getParamenters(){
        return new int[]{zzMarkedPos, zzPushbackPos, zzCurrentPos, zzStartRead, zzEndRead, yyline};
    }

    private boolean parsePHPDoc(){
        /*final IDocumentorLexer documentorLexer = getDocumentorLexer(zzReader);
        if(documentorLexer == null){
            return false;
        }
        yypushback(zzMarkedPos - zzStartRead);
        int[] parameters = getParamenters();
        documentorLexer.reset(zzReader, zzBuffer, parameters);
        Object phpDocBlock = documentorLexer.parse();
        commentList.add(phpDocBlock);
        reset(zzReader, documentorLexer.getBuffer(), documentorLexer.getParamenters());*/

        //System.out.println("#######ParsePHPDoc()");
        //return true;
        return false;
    }


    /*protected IDocumentorLexer getDocumentorLexer(java.io.Reader  reader) {
        return null;
    }*/

    public void reset(java.io.Reader  reader, char[] buffer, int[] parameters){
        this.zzReader = reader;
        this.zzBuffer = buffer;
        this.zzMarkedPos = parameters[0];
        this.zzPushbackPos = parameters[1];
        this.zzCurrentPos = parameters[2];
        this.zzStartRead = parameters[3];
        this.zzEndRead = parameters[4];
        this.yyline = parameters[5];
        //
        this.yychar = this.zzStartRead - this.zzPushbackPos;
    }

%}

LABEL=([[:letter:]_]|[\u007f-\u00ff])([[:letter:][:digit:]_]|[\u007f-\u00ff])*
OPTION = "%" + {LABEL}
NEWLINE = [\n]
WHITESPACE = [ \t\f]
LEXICAL_STATE_TAGS = "<" + {LABEL} + ("," + {WHITESPACE}* + {LABEL})* + ">" | "<<EOF>>"
REGEX_QUANTIFIER = "{" + ([0-9])+ "}"
REGEX_EXPRESSION = ("[" + ([^\[\n] | "^")+ "]" +  {REGEX_QUANTIFIER}?)+ ("|" + {WHITESPACE}* {STRING})* | ([\\] [\\]* [^\n] [\|]*)+
OTHER_EXPRESSION = [0-9] | [\\][a-z] | [a-z][\?]
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
    //KKK
    return  JflexTokenId.T_COMMENT;
}

<ST_JFLEX_OPTIONS_AND_DECLARATIONS>{NEWLINE}+ {
    //ll
    return JflexTokenId.T_NEWLINE;
}
//USER CODE
