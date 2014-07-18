# Description:
#   What is Zesty catering us today?
#
# Dependencies:
#   "request": "^2.34.0"
#   "moment": "2.0.x"
#
# Configuration:
#   HUBOT_ZESTY_ACCOUNT_NAME - In the format of http://zesty.com/ACCOUNT_NAME
#
# Commands:
#   hubot zesty - Pulls your catering menu for today
#   hubot zesty tomorrow - Tomorrow's catering menu
#
# Author:
#   jonursenbach

request = require 'request'
moment = require 'moment'
url = require 'url'

module.exports = (robot) =>
  robot.respond /zesty( .*)?/i, (msg) ->
    date = if msg.match[1] then msg.match[1].trim() else ''
    if date isnt undefined && date != ''
      date = getTimestamp(date)
      if date is false
        getCatering msg, false
      else
        getCatering msg, date
    else
      getCatering msg, moment()

getTimestamp = (date) ->
  if !isNaN(new Date(date).getTime())
    return moment(date)

  if /(today|tomorrow)/i.test(date)
    switch date
      when 'today'
        return moment()
      when 'tomorrow'
        return moment().add('d', 1)
  else
    return false

getDishModifiers = (dish) ->
  modifiers = []
  if dish.vegetarian
    modifiers.push('vegetarian')

  if dish.paleo
    modifiers.push('paleo')

  if dish.vegan
    modifiers.push('vegan')

  if dish.gluten_free
    modifiers.push('gluten free')

  return modifiers

getCatering = (msg, date) ->
  if date is false
    return msg.send 'I don\'t know when that is.'

  searchDate = date.format('YYYY-MM-DD')

  request 'http://zesty.com/' + process.env.HUBOT_ZESTY_ACCOUNT_NAME, (err, res, body) =>
    return msg.send "Unable to pull your Zesty ID. ERROR: #{err}" if err
    return msg.send "Unable to pull your Zesty ID. ERROR: #{res.statusCode + ':\n' + body}" if res.statusCode != 200

    resUrl = url.parse(res.request.uri.href);
    if resUrl.host != 'catering.zesty.com'
      return msg.send "Sorry, Zesty took us to an unexpected domain: #{resUrl.host}."

    accountId = resUrl.hash.replace(/#\//, '')

    options = {
      url: 'https://api.hastyapp.com/catering_clients/' + accountId,
      followAllRedirects: true,
      headers: {
        'Accept': 'application/json; version=2'
        'X-HASTY-API-KEY': '7f2e945f9eef4527ee6aa2be0a130718',
        'User-Agent': 'hubot-zesty (http://github.com/jonursenbach/hubot-zesty)'
      }
    }

    request options, (err, res, body) =>
      return msg.send "Unable to pull your menu. ERROR: #{err}" if err
      return msg.send "Unable to pull your menu. ERROR: #{res.statusCode + ':\n' + body}" if res.statusCode != 200

      catering = JSON.parse(body)

      for order in catering.catering_orders
        if order.delivery_date.indexOf(searchDate) != -1
          emit = 'Catering for ' + searchDate + ' is coming from ' + order.restaurant_name + '.\n\n';

          items = order.catering_order_items

          for item in catering.catering_order_items
            if items.indexOf(item.id) != -1
              for dish in catering.dishes
                if dish.id == item.dish
                  itemName = item.name.replace(/Catering: /, '');

                  modifiers = getDishModifiers(dish)
                  if modifiers.length > 0
                    emit += itemName + ' (' + modifiers.join(', ') + ')\n'
                  else
                    emit += itemName + '\n'

                  emit += ' - ' + dish.description + '\n'

                  emit += '\n'

          msg.send emit
          return

      msg.send "Sorry, I was unable to find a menu for #{searchDate}."
