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

import java.util.Collection;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;
import org.netbeans.api.java.lexer.JavaTokenId;
import org.netbeans.api.lexer.InputAttributes;
import org.netbeans.api.lexer.Language;
import org.netbeans.api.lexer.LanguagePath;
import org.netbeans.api.lexer.Token;
import org.netbeans.api.lexer.TokenId;
import org.netbeans.modules.jflex.editor.csl.JflexLanguage;
import org.netbeans.spi.lexer.LanguageEmbedding;
import org.netbeans.spi.lexer.LanguageHierarchy;
import org.netbeans.spi.lexer.Lexer;
import org.netbeans.spi.lexer.LexerRestartInfo;

/**
 *
 * @author bhaidu
 */
public enum JflexTokenId implements TokenId {
    T_JAVA("java_embedding"),
    T_JFLEX_LEXICAL_STATE_TAG("jflex_lexical_state_tag"), 
    T_JFLEX_REGEX_EXPRESSION("jflex_regex_expression"), 
    T_JFLEX_STATE_NAME("jflex_state_name"),
    T_JFLEX_DECL_WRAPPER_TAG("jflex_option"), 
    T_JFLEX_CLASS_CODE_TAG("jflex_option"),
    T_JFLEX_OPTION("jflex_option"),
    T_JFLEX_MACRO("jflex_macro"),
    T_JFLEX_JAVA_TOKEN_CONSTANT("java_token_constant"),
    T_TILDA("jflex_operator"),
    T_JFLEX_COMMA("whitespace"),
    T_WHITESPACE("whitespace"),
    T_NEWLINE("whitespace"),
    T_COMMENT("comment"),
    T_KEYWORD("keyword"),
    T_UNKNOWN("error"), 
    T_JAVA_JFLEX_STATE_NAME("jflex_state_name"), 
    T_CURLY_OPEN("whitespace"),
    T_CURLY_CLOSE("whitespace"),
    T_STRING("string"), 
    T_OPERATOR("whitespace"),
    T_OTHER("whitespace"),
    ;
    private final String primaryCategory;

    JflexTokenId(String primaryCategory) {
        this.primaryCategory = primaryCategory;
    }

    @Override
    public String primaryCategory() {
        return primaryCategory;
    }
    
    private static final Language<JflexTokenId> LANGUAGE =
            new LanguageHierarchy<JflexTokenId>() {
                @Override
                protected Collection<JflexTokenId> createTokenIds() {
                    return EnumSet.allOf(JflexTokenId.class);
                }

                @Override
                protected Map<String, Collection<JflexTokenId>> createTokenCategories() {
                    Map<String, Collection<JflexTokenId>> cats = new HashMap<String, Collection<JflexTokenId>>();
                    return cats;
                }

                @Override
                protected Lexer<JflexTokenId> createLexer(LexerRestartInfo<JflexTokenId> info) {
                   // return JflexColoringLexer.create(info);
                    return new JflexLexer(info);
                }

                @Override
                protected String mimeType() {
                    return JflexLanguage.JFLEX_MIME_TYPE;
                }

                @Override
                protected LanguageEmbedding<?> embedding(Token<JflexTokenId> token,
                        LanguagePath languagePath, InputAttributes inputAttributes) {
                    Language<?> lang = null;
                    boolean join_sections = false;
                    JflexTokenId id = token.id();

                    switch (id){
                        case T_JAVA:
                            //no break
                        case T_JAVA_JFLEX_STATE_NAME:    
                            lang = JavaTokenId.language();
                            join_sections = true;
                            break;
                    }
                    
                    if (lang != null){
                        return LanguageEmbedding.create( lang, 0, 0, join_sections );
                    }
 
                    return null;

                }
            }.language();

    public static Language<JflexTokenId> language() {
        return LANGUAGE;
    }
}
