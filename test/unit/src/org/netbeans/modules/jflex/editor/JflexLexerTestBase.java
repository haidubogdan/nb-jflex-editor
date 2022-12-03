package org.netbeans.modules.jflex.editor;

import java.io.File;
import java.lang.reflect.Field;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Map;
import org.netbeans.api.java.classpath.ClassPath;
import org.netbeans.api.lexer.TokenId;
import org.netbeans.api.lexer.TokenSequence;
import org.netbeans.junit.NbTestCase;
import org.netbeans.modules.jflex.editor.lexer.JflexTokenId;


/**
 *
 * @author bhaidu
 */
public class JflexLexerTestBase extends NbTestCase {

    public JflexLexerTestBase(String testName) {
        super(testName);
    }

    private Map<String, ClassPath> classPathsForTest;
    private Object[] extraLookupContent = null;

    @Override
    protected void setUp() throws Exception {

        super.setUp();
    }

    public File getDataDir() {
        URL codebase = getClass().getProtectionDomain().getCodeSource().getLocation();
        File dataDir = null;
        try {
            dataDir = new File(new File(codebase.toURI()), "data");
        } catch (URISyntaxException x) {
            throw new Error(x);
        }
        return dataDir;
    }
    
        protected String createResult(TokenSequence<?> ts) throws Exception {
        StringBuilder result = new StringBuilder();

        while (ts.moveNext()) {
            TokenId tokenId = ts.token().id();
            CharSequence text = ts.token().text();
            result.append("token #");
            result.append(ts.index());
            result.append(" ");
            result.append(tokenId.name());
            result.append(" “");
            result.append(JflexLexerUtils.replaceLinesAndTabs(text.toString()));
            result.append("“\n");
        }
        return result.toString();
    }

    protected String indexOf(Field[] fields, int symbol) {
        for (Field field : fields) {
            String fieldName = field.getName();
            try {
                Object value = field.get(field);
                if (value.equals(symbol)) {
                    return fieldName;
                }
            } catch (Exception ex) {

            }
//            if (field.v)
        }
        return " - undefined -";
    }

    protected String getTestResult(String filename) throws Exception {
        String content = JflexLexerUtils.getFileContent(new File(getDataDir(), "testfiles/" + filename));
        TokenSequence<?> ts = JflexLexerUtils.seqForText(content, JflexTokenId.language());
        System.out.print("\n---Lexer scan for <<" + filename + ">>\n\n");
        return createResult(ts);
    }

    protected void performTest(String filename) throws Exception {
        performTest(filename, null);
    }

    protected String getTestResult(String filename, String caretLine) throws Exception {
        return getTestResult(filename);
    }

    protected void performTest(String filename, String caretLine) throws Exception {
        // parse the file
        String result = getTestResult(filename, caretLine);
        System.out.print(result);
    }

}