module.exports = (grunt) ->
  opn             = require 'opn-bg'
  fs              = require 'fs'
  _               = require 'underscore'
  os              = require 'os'
  path            = require 'path'
  WebSocketServer = require('ws').Server

  ERROR_FILE_PATH = path.join os.tmpdir(), 'leaves-error.html'

  templateFile = path.join(path.dirname(__dirname), 'templates', 'error-page.html')
  template = _.template(fs.readFileSync(templateFile, 'utf8'))

  grunt.registerTask 'brerror:server', 'Run server to display errors in browser.', ->
    defaults =
      port: 7841
    options = _.extend defaults, grunt.config('brerror.options')

    done = this.async()

    wss = new WebSocketServer({port: options.port})
    grunt.log.writeln "WebSocket server started on port #{options.port}"

    errors = {}
    clients = {}

    currentId = 0

    showError = ->
      errorHtml = template({ errors: errors, port: options.port })
      fs.writeFileSync ERROR_FILE_PATH, errorHtml
      opn ERROR_FILE_PATH, { keepFocus: true }

    closeWindow = ->
      client.send('close') for i, client of clients

    handlers =
      error: (error) ->
        closeWindow()
        errors[error.task] = error
        showError()

      success: (task) ->
        closeWindow()
        delete errors[task]
        showError() unless _.isEmpty(errors)

    wss.on 'connection', (ws) ->
      id = currentId
      clients[id] = ws
      currentId++

      ws.on 'message', (message) ->
        message = JSON.parse message
        handlers[message.code](message.data)

      ws.on 'close', ->
        delete clients[id]
