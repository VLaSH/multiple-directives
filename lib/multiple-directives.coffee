MultipleDirectivesView = require './multiple-directives-view'
TextParser = require './text-parser'

{CompositeDisposable} = require 'atom'

module.exports = MultipleDirectives =
  multipleDirectivesView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    _this = this
    @select = false
    @clones = []
    @multipleDirectivesView = new MultipleDirectivesView(state.multipleDirectivesViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @multipleDirectivesView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    # @subscriptions.add atom.commands.add 'atom-workspace', 'multiple-directives:toggle': => @toggle()

    atom.workspace.observeTextEditors (editor) ->
      _this.subscriptions.add editor.onDidSave ->
        _this.toggle()
      _this.subscriptions.add editor.onDidStopChanging ->
        _this.select = false

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @multipleDirectivesView.destroy()

  serialize: ->
    multipleDirectivesViewState: @multipleDirectivesView.serialize()

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor.getText().match(new RegExp('\\['))
    parser = new TextParser()
    @clones = parser.parseRawText() unless @select
    @disarmClones(@clones)

  disarmClones: (clones) ->
    highlightMethod = if @select then 'remove' else 'highlight'
    armyOfClones = clones.params.concat(clones.depend)
    @multipleDirectivesView.highlightArmyOfClones(
      @searchForClones(armyOfClones), highlightMethod
    )
    @select = !@select

  # find objects that repeat several times
  searchForClones: (processedItems) ->
    clones = []
    processedItems.forEach((object, i, array) ->
      count = 1
      _i = i + 1
      while(_i < array.length)
        if object.item == array[_i].item
          count++
          clones.push(array[_i])
        _i++
    )
    clones
