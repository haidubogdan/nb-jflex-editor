package org.netbeans.modules.jflex.editor;

import org.junit.Test;


/**
 * USED JUST FOR DEBUGGING
 * 
 * @author bhaidu
 */
public class JflexColoringLexerTest extends JflexLexerTestBase {

    public JflexColoringLexerTest(String testName) {
        super(testName);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
    }
    
    
    @Test
    public void test1() throws Exception {
        performTest("lexer/test1.flex");
    }
}