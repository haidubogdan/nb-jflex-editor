package org.netbeans.modules.jflex.editor.lexer;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.netbeans.api.lexer.Token;
import org.netbeans.spi.lexer.Lexer;
import org.netbeans.spi.lexer.LexerRestartInfo;
import org.netbeans.spi.lexer.TokenFactory;
import org.openide.util.Exceptions;

/**
 *
 * @author bhaidu
 */
public class JflexLexer implements Lexer<JflexTokenId> {
    private final JflexColoringLexer scanner;
    private final TokenFactory<JflexTokenId> tokenFactory;

    public JflexLexer(LexerRestartInfo<JflexTokenId> info) {
        scanner = new JflexColoringLexer(info);
        tokenFactory = info.tokenFactory();
    }

    @Override
    public Token<JflexTokenId> nextToken() {
        try {
            JflexTokenId tokenId = scanner.findNextToken();
            Token<JflexTokenId> token = null;
            if (tokenId != null) {
                token = tokenFactory.createToken(tokenId);
            }
            return token;
        } catch (IOException ex) {
            Logger.getLogger(JflexLexer.class.getName()).log(Level.SEVERE, null, ex);
            //Exceptions.printStackTrace(ex);
        }
        return null;
    }

    @Override
    public Object state() {
        return scanner.getState();
    }

    @Override
    public void release() {
    }

}
