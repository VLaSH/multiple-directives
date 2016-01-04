{CompositeDisposable} = require 'atom'

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

  # highlight objects that repeat several times
  highlightClones: ->
