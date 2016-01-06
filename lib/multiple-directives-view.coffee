{CompositeDisposable, Range, Point} = require 'atom'

module.exports =
class MultipleDirectivesView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('multiple-directives')

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  # highlight clones that repeat several times
  highlightArmyOfClones: (clones, highlightMethod) ->
    editor = atom.workspace.getActiveTextEditor()
    ranges = []
    for clone in clones
      if highlightMethod == 'highlight'
        startPoint = clone.itemStartPos
        endPoint = clone.end
      else
        startPoint = clone.start
        endPoint = new Point(clone.end.row, clone.end.column + 1)
      ranges.push(new Range(startPoint, endPoint))

    editor.setSelectedBufferRanges(ranges) if ranges.length > 0
