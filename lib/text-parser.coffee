{CompositeDisposable, Range, Point} = require 'atom'
MultipleDirectivesView = require './multiple-directives-view'

module.exports =
class TextParser

  # parses text from editor to a hash of objects
  parseRawText: ->
    @editor = atom.workspace.getActiveTextEditor()
    declarationPartial = @getDeclarationPartial()
    dependencies = @getDependencies(declarationPartial)
    parameters = @getParameters(declarationPartial)

    { depend: dependencies, params: parameters }

  # get part of angular module declarations
  getDeclarationPartial: ->
    editor = @editor || atom.workspace.getActiveTextEditor()
    startPoint = new Point()
    endPoint = new Point()
    editor.scan(new RegExp('\\['), (object) ->
      startPoint = object.range.start
    )
    editor.scan(new RegExp('->'), (object) ->
      endPoint = object.range.start
    )
    partialRange = new Range(startPoint, endPoint)
    partialText = editor.getTextInBufferRange(partialRange)

    { text: partialText, range: partialRange }

  # parses dependencies into objects
  getDependencies: (decPartial) ->
    depend = @getItems(decPartial, new RegExp('\\['), new RegExp('\\('))
    @parseItems(depend)

  # parses parameters into objects
  getParameters: (decPartial) ->
    params = @getItems(decPartial, new RegExp('\\('), new RegExp('\\)'))
    @parseItems(params)

  # parses parameters and dependencies into objects
  parseItems: (items) ->
    rawArray = items.text.split(',')
    processedItems = []
    rawArray.forEach((item, i, array) ->
      processedItems[i] = {}

      # calculate new item position coordinates
      itemReturns = item.match(/\n/g) || ''
      itemSpaces = item.match(/\s/g) || ''
      newRow = itemReturns.length

      processedItems[i].item = item.replace(/\s/g, '')

      # get start position of item
      processedItems[i].start = calcStartPosition(items, processedItems, i)

      if newRow > 0
        newColumn = itemSpaces.length - newRow + processedItems[i].item.length
        processedItems[i].itemStartPos = new Point(
          processedItems[i].start.row + newRow,
          itemSpaces.length - newRow
        )
      else
        newColumn = processedItems[i].start.column + item.length
        processedItems[i].itemStartPos = new Point(
          processedItems[i].start.row,
          processedItems[i].start.column  + itemSpaces.length
        )

      # get end position of item
      processedItems[i].end = calcEndPosition(processedItems[i], newRow, newColumn)
    )
    processedItems

  # finds parameters or dependencies in declaration partial
  getItems: (decPartial, firstRegExp, secRegExp) ->
    editor = @editor || atom.workspace.getActiveTextEditor()
    startPoint = new Point()
    endPoint = new Point()
    editor.scanInBufferRange(firstRegExp, decPartial.range, (object) ->
      startPoint = object.range.end
    )
    editor.scanInBufferRange(secRegExp, decPartial.range, (object) ->
      endPoint = object.range.start
    )
    partialRange = new Range(startPoint, endPoint)
    partialText = editor.getTextInBufferRange(partialRange)

    { text: partialText, range: partialRange }

  # private methods
  calcStartPosition = (items, processedItems, i) ->
    if i == 0
      new Point(items.range.start.row, items.range.start.column)
    else
      new Point(processedItems[i - 1].end.row, processedItems[i - 1].end.column + 1)

  calcEndPosition = (items, row, column) ->
    new Point(items.start.row + row, column)
