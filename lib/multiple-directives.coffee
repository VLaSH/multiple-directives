MultipleDirectivesView = require './multiple-directives-view'
TextParser = require './text-parser'

{CompositeDisposable} = require 'atom'

module.exports = MultipleDirectives =
  multipleDirectivesView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    _this = this
    console.log('welcome')
    @multipleDirectivesView = new MultipleDirectivesView(state.multipleDirectivesViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @multipleDirectivesView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    # @subscriptions.add atom.commands.add 'atom-workspace', 'multiple-directives:toggle': => @toggle()

    atom.workspace.observeTextEditors (editor) ->
      _this.subscriptions.add editor.onDidSave ->
        _this.toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @multipleDirectivesView.destroy()

  serialize: ->
    multipleDirectivesViewState: @multipleDirectivesView.serialize()

  toggle: ->
    parser = new TextParser()
    object = parser.parseRawText()
    @searchForClones(object.params)

  # find objects that repeat several times
  searchForClones: (processedItems) ->
    _this = this
    processedItems.forEach((object, i, array) ->
      count = 1
      _i = i + 1
      while(_i < array.length)
        if object.item == array[_i].item
          count++
          _this.multipleDirectivesView.highlightClones(array[_i])
        _i++
    )
