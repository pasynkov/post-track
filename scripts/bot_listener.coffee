
TelegramBot = require "node-telegram-bot-api"

_ = require "underscore"
_string = require "underscore.string"
request = require "request"
async = require "async"


Tracker = require "./tracker"
StorageDecorator = require "../decorators/storage"
UtilsDecorator = require "../decorators/utils"

class BotListener

  constructor: ->

    @storageDecorator = new StorageDecorator
    @utilsDecorator = new UtilsDecorator

    @config = vakoo.configurator.config.telegram

    @bot = new TelegramBot @config.token, polling: true

    @logger = vakoo.logger.telegram

    @logger.info "Start listen events"

    @bot.on "text", @handler

    @handler {
      text: "/subscribe RK026705563CN"
      chat:
        id: 20045630
      from:
        username: 'Pasynkov'
    }


  handler: (message)=>

    @logger.info "Incoming message `#{message.text}`"

    @storageDecorator.createMessageLog message

    if message.from.username is @config.admin
      message.isAdmin = true

    try
      [messageText, command, code] = message.text.match "/(.*) (.*)$"

    unless command
      try
        [messageText, command] = message.text.match "/(.*)$"

    unless command
      @logger.info "Response `UNKNOWN_COMMAND`"
      return @bot.sendMessage message.chat.id, @config.messages.UNKNOWN_COMMAND

    if command.toLowerCase() in ["where", "track", "subscribe", "unsubscribe"]
      unless code
        @logger.info "Response `UNKNOWN_CODE`"
        return @bot.sendMessage message.chat.id, @config.messages.UNKNOWN_CODE

    action = _string.camelize "#{command.toLowerCase()}-action"

    tracker = new Tracker message, code

    unless _.isFunction(tracker[action])
      return @bot.sendMessage message.chat.id, @config.messages.UNKNOWN_COMMAND

    tracker[action] (err, results)=>
      if err
        @logger.error "Spawn err: `#{err}`"
        @storageDecorator.createErrorLog message, err
        errorMessage = @config.messages.errors[err] or @config.messages.ERROR
        return @bot.sendMessage message.chat.id, @config.messages.errors[err]

      async.mapSeries(
        results
        (result, done)=>
          if result.point

            answer = @utilsDecorator.createPointMessage result.point

            try
              @bot.sendMessage message.chat.id, answer
            catch
              @bot.sendMessage message.chat.id, @config.messages.ERROR

            setTimeout(
              ->
                done()
              500
            )

          if result.message

            try
              @bot.sendMessage message.chat.id, result.message
            catch
              @bot.sendMessage message.chat.id, @config.messages.ERROR

            setTimeout(
              ->
                done()
              500
            )

        (err)=>
          if err
            @logger.error err
          else
            @logger.info "Complete dialog"
      )






module.exports = BotListener