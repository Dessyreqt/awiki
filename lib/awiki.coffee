{CompositeDisposable} = require 'atom'
{TextEditor} = require 'atom'
Os = require 'os'

module.exports = Awiki =
  subscriptions: null
  history: []
  pathSeparator: null

  config:
    wikiLocation:
      type: 'string'
      default: ''

  activate: (state) ->
    @pathSeparator = @getPathSeparator()
    @checkWikiPath()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'awiki:openOrCreateWikiLink': => @openOrCreateWikiLink()
    @subscriptions.add atom.commands.add 'atom-workspace', 'awiki:gotoLastWikiPage': => @gotoLastWikiPage()
    @subscriptions.add atom.commands.add 'atom-workspace', 'awiki:openWikiIndex': => @openWikiIndex()

  deactivate: ->
    @subscriptions.dispose()

  #features

  getDefaultWikiPath: ->
    atom.packages.getPackageDirPaths() + "#{@pathSeparator}awiki#{@pathSeparator}wiki#{@pathSeparator}"

  openWikiLink: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    link = @linkUnderCursor(editor)
    return unless link?

    if editor.getGrammar().scopeName is 'source.wiki'
      @history.push(editor.getPath())
      newPath = @getFile(editor, link)
      atom.workspace.open(newPath)

  gotoLastWikiPage: ->
    if @history.length > 0
      newPath = @history.pop()
      atom.workspace.open(newPath)

  openWikiIndex: ->
    @checkWikiPath()
    indexDirectory = atom.config.get("awiki.wikiLocation")
    indexPath = "#{indexDirectory}index.wiki"
    atom.workspace.open(indexPath)

  openOrCreateWikiLink: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    link = @linkUnderCursor(editor)
    return @openWikiLink() if link?

    @createWikiLink(editor)

  createWikiLink: (editor) ->
    selectedText = editor.getSelectedText()

    if selectedText == ''
      selectedText = editor.getWordUnderCursor()
      currentPosition = editor.getCursorBufferPosition()
      editor.transact(0, ->
        editor.moveRight()
        editor.moveToBeginningOfWord()
        editor.selectToEndOfWord()
        editor.insertText("[[#{selectedText}]]")
        editor.setCursorBufferPosition([currentPosition.row, currentPosition.column + 2])
      )
    else
      selectedRange = editor.getSelectedBufferRange()
      editor.insertText("[[#{selectedText}]]")
      editor.setSelectedBufferRange([[selectedRange.start.row, selectedRange.start.column + 2], [selectedRange.end.row, selectedRange.end.column + 2]])

  #config functions

  checkWikiPath: ->
    wikiLocation = atom.config.get('awiki.wikiLocation')

    if wikiLocation == ''
      atom.config.set('awiki.wikiLocation', @getDefaultWikiPath())

    if wikiLocation.lastIndexOf(@pathSeparator) != wikiLocation.length - 1
      atom.config.set('awiki.wikiLocation', "#{wikiLocation}#{@pathSeparator}")

  #cross-platform functions

  getPathSeparator: ->
    if @isWindows()
      return '\\'
    return '/'

  isWindows: ->
    return Os.platform() is 'win32'

  #link functions

  linkUnderCursor: (editor) ->
    cursorPosition = editor.getCursorBufferPosition()
    link = @linkAtPosition(editor, cursorPosition)
    return link if link?

  linkAtPosition: (editor, bufferPosition) ->
    if token = editor.tokenForBufferPosition(bufferPosition)
      token.value if token.value and token.scopes.indexOf('string.other.link.wiki') > -1

  fixLinkName: (linkName) ->
    linkName = linkName.replace /(\[+|]+)/g, ""

    delimiterIndex = linkName.indexOf('|')
    if delimiterIndex > -1
      linkName = linkName.slice(0, delimiterIndex)

    return linkName

  #file functions

  getDirectory: (editor) ->
    filePath = editor.getPath()
    directory = filePath.slice(0, filePath.lastIndexOf(@pathSeparator) + 1)
    return directory

  getFile: (editor, linkName) ->
    link = @fixLinkName(linkName)
    directory = @getDirectory(editor)
    return "#{directory}#{link}.wiki"
