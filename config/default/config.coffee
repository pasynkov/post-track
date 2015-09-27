module.exports = {
  loggers:
    telegram: {}
    tracker: {}

  storage:

    redis: {}

    mongo:
      host: "db.vakoo.ru"
      name: "post_tracker"
      username: "post_tracker"
      password: "085bdb2261"

  telegram: {
    token: "137352759:AAEpZvCEXXHWCwN7JdbimyTAvaHY7c8Ewgw"
    admin: "Pasynkov"
    messages: {
      UNKNOWN_COMMAND: "UNKNOWN_COMMAND"
      UNKNOWN_CODE: "UNKNOWN_CODE"
      ERROR: "ERROR"
    }
  }

  tracker: {
    apiKey: "1f818db4501b3c473fdc91f0361286c2"
    domain: "vakoo.ru"
    apiUrl: "http://track24.ru/api/tracking.json.php"
  }

}