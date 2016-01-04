MultipleDirectivesView = require './multiple-directives-view'
{CompositeDisposable, Range, Point} = require 'atom'

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
    @editor =  atom.workspace.getActiveTextEditor()
    object = @parseRawText(@editor)

  # parse text from editor to a hash of objects
  parseRawText: (editor) ->
    declarationPartial = @getDeclarationPartial(editor)
    dependencies = @getDependencies(editor, declarationPartial)
    parametres = @getParametres(editor, declarationPartial)
    pparams = @parseParametres(parametres)

    { depend: dependencies, params: pparams }

  # get declaration part of angular module
  getDeclarationPartial: (editor) ->
    startPoint = new Point()
    endPoint = new Point()
    editor.scan(new RegExp('angular'), (object) ->
      startPoint = object.range.start
    )
    editor.scan(new RegExp('->'), (object) ->
      endPoint = object.range.start
    )
    partialRange = new Range(startPoint, endPoint)
    partialText = editor.getTextInBufferRange(partialRange)

    { text: partialText, range: partialRange }

  # parse included dependencies to objects
  getDependencies: (editor, decPartial) ->
    startPoint = new Point()
    endPoint = new Point()
    editor.scanInBufferRange(/\[/, decPartial.range, (object) ->
      startPoint = object.range.end
    )
    editor.scanInBufferRange(/\(/, decPartial.range, (object) ->
      endPoint = object.range.start
    )
    partialRange = new Range(startPoint, endPoint)
    partialText = editor.getTextInBufferRange(partialRange)

    { text: partialText, range: partialRange }

  # parse method params to objects
  getParametres: (editor, decPartial) ->
    startPoint = new Point()
    endPoint = new Point()
    editor.scanInBufferRange(/\(/, decPartial.range, (object) ->
      startPoint = object.range.end
    )
    editor.scanInBufferRange(/\)/, decPartial.range, (object) ->
      endPoint = object.range.start
    )
    partialRange = new Range(startPoint, endPoint)
    partialText = editor.getTextInBufferRange(partialRange)

    { text: partialText, range: partialRange }

  parseParametres: (params) ->
    rawArray = params.text.split(',')
    parametres = []
    row = 0
    rawArray.forEach((item, i, array) ->
      parametres[i] = {}
      if i == 0
        parametres[i].start = params.range.start.column
      else
        parametres[i].start = parametres[i - 1].end + 1

      parametres[i].end = parametres[i].start + item.length
      parametres[i].item = item.replace(/\s/g, '')
      # console.log(item.replace(/\n/g, '-').match(/-/g).length if item.replace(/\n/g, '-').match(/-/g))
    )
    parametres

  # find objects that repeat several times
  searchForClones: (editor, objects) ->

  # remove objects that repeat several times
  removeClones: (editor, clones) ->
