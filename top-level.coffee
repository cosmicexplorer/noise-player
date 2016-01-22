byline = require 'byline'
hasbin = require 'hasbin'
commands = require './commands'

process.argv.shift()
process.argv.shift()
if process.argv.length < 2
  process.stderr.write '''
  Usage: coffee noise-player.coffee PORT PASSWORD

  The choice of password can be arbitrary if you're not using it for anything
  else.
  '''
  process.exit 1
if not hasbin.sync 'cvlc'
  process.stderr.write 'cvlc binary required on PATH!'
  process.exit 1

ctx = new commands.QueueContext process.argv[0], process.argv[1], process.stdout

makeErrorResponse = (txt) -> {error: yes, text: txt}

noSuchCommand = (cmd) -> makeErrorResponse "No such command (#{cmd}) found."

class ReadWithCallback extends require('stream').Writable
  constructor: (@cb) -> super(objectMode: no)
  _write: (chunk, enc, cb) ->
    @cb chunk.toString(), cb

byline(process.stdin).pipe new ReadWithCallback (data, cb) ->
  {command, argument} = JSON.parse data
  if ctx[command]?
    ctx[command] argument, cb
  else
    process.stderr.write noSuchCommand(command)
    cb()
