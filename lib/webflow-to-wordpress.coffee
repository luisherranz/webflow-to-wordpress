WebflowToWordpressView = require './webflow-to-wordpress-view'
{CompositeDisposable} = require 'atom'

module.exports = WebflowToWordpress =
  webflowToWordpressView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @webflowToWordpressView = new WebflowToWordpressView(state.webflowToWordpressViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @webflowToWordpressView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'webflow-to-wordpress:process': => @process()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @webflowToWordpressView.destroy()

  serialize: ->
    webflowToWordpressViewState: @webflowToWordpressView.serialize()

  process: ->
    console.log 'WebflowToWordpress was processed!'

    editor = atom.workspace.getActivePaneItem()

    ## remove wf data from html
    iterator = ( object ) -> object.replace "<html>"
    editor.scan(/<html.+>/g, iterator )

    ## remove title
    iterator = ( object ) -> object.replace "<title><?php wp_title( '|', true, 'right' ); ?></title>"
    editor.scan(/<title>.+<\/title>/g, iterator )

    ## add wp_head
    iterator = ( object ) -> object.replace '<?php wp_head(); ?></head>'
    editor.scan(/^\s*<\/head>/g, iterator )

    ## images
    iterator = ( object ) -> object.replace 'src="<?php echo get_stylesheet_directory_uri() ?>/webflow/images'
    editor.scan(/src="images/g, iterator )

    ## js
    iterator = ( object ) -> object.replace 'src="<?php echo get_stylesheet_directory_uri() ?>/webflow/js'
    editor.scan(/src="js/g, iterator )

    ## css
    iterator = ( object ) -> object.replace 'href="<?php echo get_stylesheet_directory_uri() ?>/webflow/css'
    editor.scan(/href="css/g, iterator )

    ## favicon
    iterator = ( object ) -> object.replace 'href="/favicon.ico">'
    editor.scan(/href="http.+favicon\.ico">/g, iterator )

    ## remove index.html
    iterator = ( object ) -> object.replace '/"'
    editor.scan(/index\.html"/g, iterator )

    ## add / to links
    iterator = ( object ) -> object.replace "/#{object.matchText}"
    editor.scan(/[a-zA-Z0-9-]+\.html"/g, iterator )

    ## remove .html's
    iterator = ( object ) -> object.replace "\""
    editor.scan(/\.html"/g, iterator )

    ## add footer changes
    iterator = ( object ) -> object.replace "<?php wp_footer(); ?>"
    editor.scan(/<script type="text\/javascript" src="https:\/\/ajax\.googleapis\.com\/ajax\/libs\/jquery\/1\.11\.1\/jquery\.min\.js"><\/script>/g, iterator )
