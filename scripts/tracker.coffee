
url = require "url"
request = require "request"
async = require "async"
_ = require "underscore"
moment = require("moment")

StorageDecorator = require "../decorators/storage"

class Tracker

  constructor: (@message, @code)->

    @logger = vakoo.logger.tracker
    @config = vakoo.configurator.config.tracker
    @storageDecorator = new StorageDecorator

  whereAction: (callback)=>

    @logger.info "Run `where` action with code `#{@code}`"

    async.waterfall(
      [
        async.apply async.parallel, {
          storedTrack: async.apply @storageDecorator.getTrack, @code
          track: async.apply @apiRequest, {code: @code}
        }
        ({storedTrack, track}, taskCallback)=>

          if storedTrack
            @storageDecorator.updateTrack @code, track, (err)->
              taskCallback err, track
          else
            @storageDecorator.storeTrack @code, track, (err)->
              taskCallback err, track

        (track, taskCallback)=>
          taskCallback null, [point: track.data.lastPoint]
      ]
      callback
    )

  trackAction: (callback)=>

    @logger.info "Run `track` action with code `#{@code}`"

    async.waterfall(
      [
        async.apply async.parallel, {
          storedTrack: async.apply @storageDecorator.getTrack, @code
          track: async.apply @apiRequest, {code: @code}
        }
        ({storedTrack, track}, taskCallback)=>
          if storedTrack
            @storageDecorator.updateTrack @code, track, (err)->
              taskCallback err, track
          else
            @storageDecorator.storeTrack @code, track, (err)->
              taskCallback err, track
        (track, taskCallback)=>
          taskCallback null, _.map(
            _.sortBy(
              track.data.events
              (e)->
                moment(e.operationDateTime, "DD.MM.YYYY HH:mm:ss").toDate()
            )
            (event)->
              point: event
          )
      ]
      callback
    )


  trekAction: (callback)=>
    @trackAction callback


  apiRequest: (params, callback)=>

    apiUrlObject = url.parse @config.apiUrl
    apiUrlObject.query = _.defaults {
      domain: @config.domain
      apiKey: @config.apiKey
    }, params

    requestUrl = url.format apiUrlObject

    request requestUrl, (err, res, body)=>

      if err
        return callback err

      if res.statusCode isnt 200
        return callback "Code isnt 200 with body `#{body}`"

      try
        result = JSON.parse body
        callback null, result
      catch
        return callback "Cannot parse json"

module.exports = Tracker