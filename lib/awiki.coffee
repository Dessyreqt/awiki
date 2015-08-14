{CompositeDisposable} = require 'atom'
{TextEditor} = require 'atom'
Os = require 'os'

debugInfo = false

module.exports = Awiki =
  subscriptions: null
  history: []

  config:
    wikiLocation:
      type: 'string'
      default: ''

  activate: (state) ->
    if atom.config.get('awiki.wikiLocation') == ''
      atom.config.set('awiki.wikiLocation', @getDefaultWikiPath())

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'awiki:openWikiLink': => @openWikiLink()
    @subscriptions.add atom.commands.add 'atom-workspace', 'awiki:gotoLastWikiPage': => @gotoLastWikiPage()
    @subscriptions.add atom.commands.add 'atom-workspace', 'awiki:openWikiIndex': => @openWikiIndex()

  deactivate: ->
    @subscriptions.dispose()

  getDefaultWikiPath: ->
    atom.packages.getPackageDirPaths() + '\\awiki\\wiki\\'

  openWikiLink: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    link = linkUnderCursor(editor)
    return unless link?

    if editor.getGrammar().scopeName is 'source.wiki'
      @history.push(editor.getPath())
      newPath = getFile(editor, link)
      openOrCreate(newPath)
      if debugInfo
        atom.notifications.addInfo(newPath)

  gotoLastWikiPage: ->
    if @history.length > 0
      newPath = @history.pop()
      if debugInfo
        atom.notifications.addInfo(newPath)
      atom.workspace.open(newPath)

  openWikiIndex: ->
    indexDirectory = atom.config.get("awiki.wikiLocation")
    indexPath = "#{indexDirectory}index.wiki"
    if debugInfo
      atom.notifications.addInfo(indexPath)
    atom.workspace.open(indexPath)

linkUnderCursor = (editor) ->
  cursorPosition = editor.getCursorBufferPosition()
  link = linkAtPosition(editor, cursorPosition)
  return link if link?

linkAtPosition = (editor, bufferPosition) ->
  if token = editor.tokenForBufferPosition(bufferPosition)
    token.value if token.value and token.scopes.indexOf('string.other.link.wiki') > -1

fixLinkName = (linkName) ->
  linkName.replace /(\[+|]+)/g, ""

getDirectory = (editor) ->
  filePath = editor.getPath()
  directory = filePath.slice(0, filePath.lastIndexOf('\\') + 1)
  return directory

getFile = (editor, linkName) ->
  link = fixLinkName(linkName)
  directory = getDirectory(editor)
  return "#{directory}#{link}.wiki"

openOrCreate = (filePath) ->
  atom.workspace.open(filePath)
