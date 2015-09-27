
moment = require("moment")
moment.locale("ru")

class UtilsDecorator

  constructor: ->


  createPointMessage: (point)=>
    eventMoment = moment(point.operationDateTime, "DD.MM.YYYY HH:mm:ss")
    fromNowDate = eventMoment.fromNow()
    calendarDate = eventMoment.format("lll")

    message = """
      #{fromNowDate} (#{calendarDate})
      #{point.operationAttribute} #{if point.operationType then "( #{point.operationType} )" else ""}
      #{if point.operationPlacePostalCode then "#{point.operationPlacePostalCode}, "  else ""}#{point.operationPlaceName}

      Обработчик: #{point.serviceName}
      #{if point.itemWeight then "Вес: #{point.itemWeight} гр." else ""}
    """

    return message

module.exports = UtilsDecorator