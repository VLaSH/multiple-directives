MultipleDirectivesView = require './multiple-directives-view'
{CompositeDisposable} = require 'atom'

module.exports = MultipleDirectives =
  multipleDirectivesView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @multipleDirectivesView = new MultipleDirectivesView(state.multipleDirectivesViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @multipleDirectivesView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'multiple-directives:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @multipleDirectivesView.destroy()

  serialize: ->
    multipleDirectivesViewState: @multipleDirectivesView.serialize()

  toggle: ->
    console.log 'MultipleDirectives was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
