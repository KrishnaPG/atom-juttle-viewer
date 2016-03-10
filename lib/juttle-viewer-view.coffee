{ScrollView} = require 'atom-space-pen-views'
JuttleClient = require 'juttle-client-library'

module.exports =
class JuttleViewerView extends ScrollView
  @content: ->
    @div class: 'juttle-viewer native-key-bindings', tabindex: -1

  constructor: (@editorId) ->
    super

    @_haveShownInputsUnsupportedWarning = false
    @juttleClientViews = new JuttleClient.Views(atom.config.get('juttle-viewer.juttleServiceHost'), @element)

    @juttleClientViews.on 'error', @_showError
    @juttleClientViews.on 'warning', @_showWarning

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

  destroy: ->
    @juttleClientViews.stop()
    @juttleClientViews.removeListeners('error', @_showError)
    @juttleClientViews.removeListeners('warning', @_showWarning)

  run: ->
    text = @editorForId(@editorId).getText()
    bundle = {
      program: text
    }
    httpClient = new JuttleClient.HttpApi('http://' + atom.config.get('juttle-viewer.juttleServiceHost'))
    httpClient.getInputs(bundle).then( (inputs) =>
      if inputs.length > 0 && !@_haveShownInputsUnsupportedWarning
        atom.notifications.addWarning('Inputs are currently not supported', {
          dismissable: true,
          detail: "Atom Juttle Viewer currently doesn't render inputs. Please set -default option to the value you want juttle to use for each input."
        })
        @_haveShownInputsUnsupportedWarning = true
      @juttleClientViews.run(bundle)
    ).catch (err) =>
        @_showError(err)
