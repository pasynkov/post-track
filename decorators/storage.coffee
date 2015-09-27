

LOGS_MESSAGE_COLL = "logs_message"
LOGS_ERROR_COLL = "logs_error"
TRACKS_COLL = "tracks"

class StorageDecorator

  constructor: ->

    @mongo = vakoo.mongo

    @logger = vakoo.logger.storage



  createMessageLog: (message)=>

    message.date = new Date

    @mongo.collectionNative(LOGS_MESSAGE_COLL).insert message, (err)=>
      if err
        @logger.error err
      else
        @logger.info "Message log created"

  getTrack: (code, callback)=>

    @mongo.collectionNative(TRACKS_COLL).findOne {code}, callback

  storeTrack: (code, track, callback)=>

    @mongo.collectionNative(TRACKS_COLL).insert {code, track}, callback

  updateTrack: (code, track, callback)=>

    @mongo.collectionNative(TRACKS_COLL).update {code}, {$set: {track}}, callback

  createErrorLog: (message, error)=>

    @mongo.collectionNative(LOGS_ERROR_COLL).insert {
      date: new Date
      message
      error
    }, (err)=>
      if err
        @logger.error err
      else
        @logger.info "Error log created"

module.exports = StorageDecorator