url = require 'url'

{CompositeDisposable} = require 'atom'

JuttleViewerView = null

module.exports = JuttleVewer =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'juttle-viewer:run': => @run()

    atom.workspace.addOpener (uriToOpen) =>
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      return unless protocol is 'juttle-viewer:'

      @createJuttleViewerView(pathname.substring(1))

  uriForEditor: (editor) ->
    "juttle-viewer://editor/#{editor.id}"

  createJuttleViewerView: (state) ->
    JuttleViewerView ?= require './juttle-viewer-view'
    new JuttleViewerView(state)

  deactivate: ->
    @subscriptions.dispose()

  run: ->
    editor = atom.workspace.getActiveTextEditor()

    if editor.getPath().indexOf('.juttle') == -1
      return

    uri = @uriForEditor(editor)

    currentText = editor.getText()

    options =
      searchAllPanes: true
      split: 'right'

    atom.workspace.open(uri, options).then (juttleViewerView) ->
      juttleViewerView.run()
