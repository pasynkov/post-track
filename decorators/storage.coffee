

LOGS_MESSAGE_COLL = "logs_message"
LOGS_ERROR_COLL = "logs_error"
TRACKS_COLL = "tracks"
SUBSCRIBE_COLL = "subscribe"

async = require "async"

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


  getSubscriber: (message, callback)=>
    async.waterfall(
      [
        async.apply @mongo.collection(SUBSCRIBE_COLL).findOne, {chat_id: message.chat.id}
        (subscriber, taskCallback)=>
          if subscriber

            taskCallback null, subscriber

          else

            object = {
              chat_id: message.chat.id
              user: message.from
              chat: message.chat
              subscribe: []
              unsubscribe: []
            }

            @mongo.collectionNative(SUBSCRIBE_COLL).insert object, (err, result)->
              taskCallback err, result.ops[0]
      ]
      callback
    )

  subscribe: (message, code, callback)=>

    async.waterfall(
      [
        async.apply @getSubscriber, message

        (subscriber, taskCallback)=>

          @mongo.collectionNative(SUBSCRIBE_COLL)
          .update {_id: subscriber._id}, {$addToSet: {subscribe: {code, lastEvent: 0, timestamp: new Date()}}}, (err)->
            taskCallback err, subscriber
      ]
      callback
    )

  unsubscribe: (message, code, callback)=>



module.exports = StorageDecorator