{ScrollView} = require 'atom-space-pen-views'
JuttleClient = require 'juttle-client-library'

module.exports =
class JuttleViewerView extends ScrollView
  @content: ->
    @div class: 'juttle-viewer native-key-bindings', tabindex: -1

  constructor: (@editorId) ->
    super
    juttleClient = new JuttleClient(atom.config.get('juttle-viewer.juttleServiceHost'))
    @juttleClientView = new juttleClient.View(@element);

    @juttleClientView.on 'error', (err) =>
      @_showError(err)

    @juttleClientView.on 'warning', (warn) =>
      @_showWarning(warn)

  _showError: (err) ->
    message = err?.info?.err?.message || err.message
    atom.notifications.addError(message, {dismissable: true})

  _showWarning: (warn) ->
    message = warn?.info?.err?.message || warn.message
    atom.notifications.addWarning(message, {dismissable: true})

  editorForId: (editorId) ->
    for editor in atom.workspace.getTextEditors()
      return editor if editor.id?.toString() is editorId.toString()
    null

  getTitle: ->
    path = @editorForId(@editorId)?.getPath()
    if path then path.substring(path.lastIndexOf('/') + 1) else '[unknown]'

  getURI: ->
    return "juttle-viewer://editor/#{@editorId}"

  run: ->
    text = @editorForId(@editorId).getText()
    @juttleClientView.run({ program: text }).catch (err) =>
      @_showError(err)
