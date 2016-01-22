{spawn, spawnSync} = require 'child_process'
http = require 'http'

{parseString} = require 'xml2js'
async = require 'async'

makeDecoderProcessAtTime = (backend, filename, time) ->

vlcHost = 'localhost'

makeRealRequest = (port, pass, str, cb) ->
  loc = "http://#{vlcHost}:#{port}/requests/status.xml#{str}"
  auth = 'Basic ' + new Buffer(":#{pass}").toString('base64')
  http.request 'GET', loc, {Authorization: auth}, cb

makeRequest = (port, pass, str, cb) ->
  makeRealRequest port, pass, "?command=#{str}", cb

streamToString = (stream, cb) ->
  str = ''
  stream.on('data', (data) ->
    str += data.toString()).on 'end', -> cb str

parsePlaylist = (stream, cb) ->
  streamToString stream, (str) ->
    parseString str, (err, res) ->
      throw err if err
      cb null, res.node.node[0].leaf.map (listing) -> listing.$.uri

makePlaylistRequest = (port, pass, cb) ->
  auth = 'Basic ' + ":#{pass}"
  console.error "auth: #{auth}"
  http.request {
    method: 'GET', path: '/requests/playlist.xml',
    host: vlcHost, port: port,
    headers: {Authorization: auth}},
    (err, res) ->
      console.log "HEY"
      throw err if err
      parsePlaylist res, cb

class QueueContext
  constructor: (@port, @password, @infoStream) -> @restart(->)
  restart: (cb) ->
    spawnSync 'cvlc', ['--one-instance', 'vlc://quit']
    @playProc = spawn 'cvlc', ['--one-instance'
                               '--extraintf=http'
                               "--http-port=#{@port}"
                               "--http-host=#{vlcHost}"
                               "--http-password=#{@password}"]
    cb()
  clear: (_, cb) -> makeRequest @port, @password, 'pl_empty', cb
  stop: (_, cb) -> makeRequest @port, @password, 'pl_stop', cb
  loop_on: (_, cb) -> makeRealRequest @port, @password, '', (err, res) =>
    throw err if err
    streamToString res, (str) =>
      parseString str, (err, xml) =>
        throw err if err
        if xml.root.loop then cb()
        else makeRequest @port, @password, 'pl_loop', cb
  loop_off: (_, cb) -> makeRealRequest @port, @password, '', (err, res) =>
    throw err if err
    streamToString res, (str) =>
      parseString str, (err, xml) =>
        throw err if err
        if not xml.root.loop then cb()
        else makeRequest @port, @password, 'pl_loop', cb
  random_on: (_, cb) -> makeRealRequest @port, @password, '', (err, res) =>
    throw err if err
    streamToString res, (str) =>
      parseString str, (err, xml) =>
        throw err if err
        if xml.root.random then cb()
        else makeRequest @port, @password, 'pl_loop', cb
  random_on: (_, cb) -> makeRealRequest @port, @password, '', (err, res) =>
    throw err if err
    streamToString res, (str) =>
      parseString str, (err, xml) =>
        throw err if err
        if not xml.root.random then cb()
        else makeRequest @port, @password, 'pl_loop', cb
  interrupt: (queue, cb) -> @stop null, => @enqueue queue, => @play cb
  enqueue: (queue, cb) ->
    async.map(queue, ((item, mcb) =>
      str = "in_enqueue&input=#{item}"
      makeRequest @port, @password, str, mcb),
      cb)
  pause: (_, cb) -> makeRequest @port, @password, 'pl_forcepause', cb
  play: (file, cb) -> makeRequest @port, @password, 'pl_forceresume', cb
  seek: (time, cb) -> makeRequest @port, @password, "seek&val=#{time}", cb
  next: (_, cb) -> makeRequest @port, @password, 'pl_next', cb
  prev: (_, cb) -> makeRequest @port, @password, 'pl_previous', cb
  'get-queue': (_, cb) ->
    makePlaylistRequest @port, @password, (err, res) =>
      throw err if err
      console.error "res: #{res}"
      @infoStream.write JSON.stringify res
      cb()

module.exports = {
  QueueContext
}
