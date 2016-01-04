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

  # parse text from editor to a hash of objects
  parseRawText: (rawText) ->

  # get declaration part of angular module
  getDeclarationPartial: (rawText) ->

  # parse included dependencies to objects
  getDependencies: (decPartial) ->

  # parse method params to objects
  getParametres: (decPartial) ->

  # find objects that repeat several times
  searchForClones: (objects) ->

  # remove objects that repeat several times
  removeClones: (clones) ->
