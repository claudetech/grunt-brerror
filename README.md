# Grunt browser error

A Grunt plugin to display compile errors directly in your browser.
The error tab is closed when the failing task(s) succeed.

## Disclaimer

This module is still very experimental.
Contributions are very welcome.

## Installation

Just run

```
npm install --save-dev grunt-brerror
```

and you are done.

## Screencast

![Screencast](http://res.cloudinary.com/dtdu3sqtl/image/upload/v1408153873/optimised_pozz3l.gif)

## Usage

You need to run the task `brerror:server` before anything.
This tasks blocks, so you must run it using [grunt-concurrent](https://github.com/sindresorhus/grunt-concurrent) or something similar.

After, just prepend `brerror:` to the task for which you want to
display errros in your browser.

Here is a sample configuration.

```coffee
module.exports = (grunt) ->
  grunt.initConfig
    watch:
      scripts:
        files: 'src/**/*.coffee'
        tasks: ['brerror:coffee:dev']

    coffee:
      dev:
        files: [
          expand: true
          src: ['src/**/*.coffee']
          dest: 'js'
          ext: '.js'
        ]

    concurrent:
      default:
        tasks: ['watch', 'brerror:server']
        options:
          logConcurrentOutput: true

    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-concurrent'
    grunt.loadNpmTasks 'grunt-brerror'

    grunt.registerTask 'default', ['concurrent:default']
```

## How does it work

This module uses websockets for IPC and to close the
browser tabs.

The `brerror:server` task runs the websocket server.
During the `brerror` task, a connection is made after the build,
and the status of the build is sent with the output.
The output is collected by hooking `grunt.log` methods.

The server then closes the tab with websokets, and displays the error page when necessary.

## Known limitations

* Does not seem to work with `spanw: false` for watch task
* Probably buggy if compile tasks are run concurrently
