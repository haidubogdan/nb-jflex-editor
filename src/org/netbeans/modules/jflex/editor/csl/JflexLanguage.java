package org.netbeans.modules.jflex.editor.csl;

import org.netbeans.api.annotations.common.StaticResource;
import org.netbeans.api.lexer.Language;
import org.netbeans.core.spi.multiview.MultiViewElement;
import org.netbeans.core.spi.multiview.text.MultiViewEditorElement;
import org.netbeans.modules.csl.spi.DefaultLanguageConfig;
import org.netbeans.modules.csl.spi.LanguageRegistration;
import static org.netbeans.modules.jflex.editor.csl.JflexLanguage.ACTIONS;
import static org.netbeans.modules.jflex.editor.csl.JflexLanguage.JFLEX_MIME_TYPE;
import org.netbeans.modules.jflex.editor.lexer.JflexTokenId;
import org.openide.awt.ActionID;
import org.openide.awt.ActionReference;
import org.openide.awt.ActionReferences;
import org.openide.filesystems.MIMEResolver;
import org.openide.util.Lookup;
import org.openide.util.NbBundle;
import org.openide.windows.TopComponent;

/**
 *
 * @author bhaidu
 */
@MIMEResolver.ExtensionRegistration(
        displayName = "Jflex",
        extension = "flex",
        mimeType = JFLEX_MIME_TYPE, position = 1
)
@LanguageRegistration(mimeType = JFLEX_MIME_TYPE, useMultiview = true)
@ActionReferences({
    @ActionReference(id = @ActionID(category = "System", id = "org.openide.actions.OpenAction"), path = ACTIONS, position = 100),
    @ActionReference(id = @ActionID(category = "Edit", id = "org.openide.actions.CutAction"), path = ACTIONS, position = 300, separatorBefore = 200),
    @ActionReference(id = @ActionID(category = "Edit", id = "org.openide.actions.CopyAction"), path = ACTIONS, position = 400),
    @ActionReference(id = @ActionID(category = "Edit", id = "org.openide.actions.PasteAction"), path = ACTIONS, position = 500, separatorAfter = 600),
    @ActionReference(id = @ActionID(category = "System", id = "org.openide.actions.NewAction"), path = ACTIONS, position = 700),
    @ActionReference(id = @ActionID(category = "Edit", id = "org.openide.actions.DeleteAction"), path = ACTIONS, position = 800),
    @ActionReference(id = @ActionID(category = "System", id = "org.openide.actions.RenameAction"), path = ACTIONS, position = 900, separatorAfter = 1000),
    @ActionReference(id = @ActionID(category = "System", id = "org.openide.actions.SaveAsTemplateAction"), path = ACTIONS, position = 1100, separatorAfter = 1200),
    @ActionReference(id = @ActionID(category = "System", id = "org.openide.actions.FileSystemAction"), path = ACTIONS, position = 1300, separatorAfter = 1400),
    @ActionReference(id = @ActionID(category = "System", id = "org.openide.actions.ToolsAction"), path = ACTIONS, position = 1500),
    @ActionReference(id = @ActionID(category = "System", id = "org.openide.actions.PropertiesAction"), path = ACTIONS, position = 1600)
})
public class JflexLanguage extends DefaultLanguageConfig {
    @StaticResource
    public static final String ICON = "org/netbeans/modules/jflex/editor/resources/icon.png";
        
    public static final String ACTIONS = "Loaders/text/x-jflex/Actions"; //NOI18N
    public static final String JFLEX_MIME_TYPE = "text/x-jflex"; //NOI18N

    @NbBundle.Messages("CTL_SourceTabCaption=&Source")
    @MultiViewElement.Registration(
            displayName = "#CTL_SourceTabCaption",
            iconBase = "org/netbeans/modules/jflex/editor/resources/icon.png",
            mimeType = JflexLanguage.JFLEX_MIME_TYPE,
            persistenceType = TopComponent.PERSISTENCE_ONLY_OPENED,
            preferredID = "Jflex",
            position = 1
    )
    public static MultiViewEditorElement createEditor(Lookup lkp) {
        return new MultiViewEditorElement(lkp);
    }
    @Override
    public Language<JflexTokenId> getLexerLanguage() {
        return JflexTokenId.language();
    }

    @Override
    public String getDisplayName() {
        return "Jflex"; //NOI18N
    }

    @Override
    public String getPreferredExtension() {
        return "jflex"; // NOI18N
    }
    
    @Override
    public String getLineCommentPrefix() {
        return "//"; //NOI18N
    }
}
