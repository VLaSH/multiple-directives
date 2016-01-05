{CompositeDisposable, Range, Point} = require 'atom'
MultipleDirectivesView = require './multiple-directives-view'

module.exports =
class TextParser

  # parse text from editor to a hash of objects
  parseRawText: ->
    @editor = atom.workspace.getActiveTextEditor()
    declarationPartial = @getDeclarationPartial()
    dependencies = @getDependencies(declarationPartial)
    processedItems = @getParametres(declarationPartial)
    pparams = @parseParametres(processedItems)

    { depend: dependencies, params: pparams }

  # get declaration part of angular module
  getDeclarationPartial: ->
    startPoint = new Point()
    endPoint = new Point()
    @editor.scan(new RegExp('angular'), (object) ->
      startPoint = object.range.start
    )
    @editor.scan(new RegExp('->'), (object) ->
      endPoint = object.range.start
    )
    partialRange = new Range(startPoint, endPoint)
    partialText = @editor.getTextInBufferRange(partialRange)

    { text: partialText, range: partialRange }

  # parse included dependencies to objects
  getDependencies: (decPartial) ->
    startPoint = new Point()
    endPoint = new Point()
    @editor.scanInBufferRange(/\[/, decPartial.range, (object) ->
      startPoint = object.range.end
    )
    @editor.scanInBufferRange(/\(/, decPartial.range, (object) ->
      endPoint = object.range.start
    )
    partialRange = new Range(startPoint, endPoint)
    partialText = @editor.getTextInBufferRange(partialRange)

    { text: partialText, range: partialRange }

  # parse method params to objects
  getParametres: (decPartial) ->
    startPoint = new Point()
    endPoint = new Point()
    @editor.scanInBufferRange(/\(/, decPartial.range, (object) ->
      startPoint = object.range.end
    )
    @editor.scanInBufferRange(/\)/, decPartial.range, (object) ->
      endPoint = object.range.start
    )
    partialRange = new Range(startPoint, endPoint)
    partialText = @editor.getTextInBufferRange(partialRange)

    { text: partialText, range: partialRange }

  parseParametres: (params) ->
    rawArray = params.text.split(',')
    processedItems = []
    rawArray.forEach((item, i, array) ->
      processedItems[i] = {}

      # calculate new item position coordinates
      itemReturns = item.match(/\n/g) || ''
      itemSpaces = item.match(/\s/g) || ''
      newRow = itemReturns.length

      processedItems[i].item = item.replace(/\s/g, '')

      # get start position of item
      processedItems[i].start = calcStartPosition(params, processedItems, i)

      if newRow > 0
        newColumn = itemSpaces.length - newRow + processedItems[i].item.length
        processedItems[i].itemStartPos = new Point(processedItems[i].start.row + newRow, itemSpaces.length - newRow)
      else
        newColumn = processedItems[i].start.column + item.length
        processedItems[i].itemStartPos = new Point(processedItems[i].start.row, processedItems[i].start.column  + itemSpaces.length)

      # get end position of item
      processedItems[i].end = calcEndPosition(processedItems[i], newRow, newColumn)
    )
    processedItems

  # private methods
  calcStartPosition = (params, processedItems, i) ->
    if i == 0
      new Point(params.range.start.row, params.range.start.column)
    else
      new Point(processedItems[i - 1].end.row, processedItems[i - 1].end.column + 1)

  calcEndPosition = (params, row, column) ->
    new Point(params.start.row + row, column)
