module.exports = (grunt) ->
  WebSocket = require('ws')
  _         = require 'underscore'

  forceFlag = grunt.option('force')

  buffer = null
  currentTask = null
  error = null
  errors = {}
  hooksRegistered = false

  registerHooks = ->
    return if hooksRegistered
    appendBuffer = (msg) -> buffer += msg
    appendBufferLn = (msg) -> appendBuffer(msg + "\n")
    grunt.util.hooker.hook grunt.log, 'write', appendBuffer
    grunt.util.hooker.hook grunt.log, 'writeln', appendBufferLn
    grunt.util.hooker.hook grunt.log, 'error', appendBufferLn
    hooksRegistered = true

  resetValues = ->
    error = null
    buffer = ''
    currentTask = null

  cleanContent = (desc) ->
    desc.replace /\[(1;)?[0-9]{1,2}m/g, ''

  grunt.registerTask 'brerror:done', ->
    done = @async()
    defaults =
      port: 7841

    options = _.extend defaults, grunt.config('brerror.options')

    ws = new WebSocket("ws://localhost:#{options.port}")
    ws.on 'open', ->
      if error == null
        ws.send JSON.stringify({code: 'success',  data: currentTask })
      else
        ws.send JSON.stringify(
          code: 'error'
          data:
            task: currentTask
            description: error
            content: cleanContent(buffer)
        )

      grunt.option 'force', forceFlag
      done()

  grunt.registerTask 'brerror', (task...) ->
    task = task.join ':'
    currentTask = task
    buffer = ''

    # grunt.fail behavior seems to differ from grunt.log functions
    grunt.util.hooker.hook grunt.fail, 'warn', ( (e) -> error = e )

    registerHooks()
    resetValues()

    grunt.option 'force', true
    grunt.task.run task
    grunt.task.run 'brerror:done'
