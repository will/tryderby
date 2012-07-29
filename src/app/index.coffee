derby = require 'derby'
{get, view, ready} = derby.createApp module
derby.use(require '../../ui')

## ROUTES ##

start = +new Date()

# Derby routes can be rendered on the client and the server
get '/:roomName?', (page, model, {roomName}) ->
  roomName ||= 'home'

  # Subscribes the model to any updates on this room's object. Calls back
  # with a scoped model equivalent to:
  #   room = model.at "rooms.#{roomName}"
  model.subscribe "rooms.#{roomName}", (err, room) ->
    room.setNull 'items', [
      { name: 'Cat', price: 3.22,  url: '/p/0' }
      { name: 'Dog', price: 10.99, url: '/p/1' },
      { name: 'Bat', price: 14.22, url: '/p/2' },
      { name: 'r ' + roomName, price: 14.22, url: '/p/3' },
    ]

    model.ref '_room', room

    # setNull will set a value if the object is currently null or undefined
    room.setNull 'welcome', "Welcome to #{roomName}!"

    room.incr 'visits'

    # This value is set for when the page initially renders
    model.set '_timer', '0.0'
    # Reset the counter when visiting a new route client-side
    start = +new Date()

    # Render will use the model data as well as an optional context object
    page.render
      roomName: roomName
      randomUrl: parseInt(Math.random() * 1e9).toString(36)


## CONTROLLER FUNCTIONS ##

ready (model) ->
  @upcase = (e, el, next) ->
    item = model.at el
    console.log item.path()
    item.set 'name', item.get('name').toUpperCase()

  timer = null

  # Functions on the app can be bound to DOM events using the "x-bind"
  # attribute in a template.
  @stop = ->
    # Any path name that starts with an underscore is private to the current
    # client. Nothing set under a private path is synced back to the server.
    model.set '_stopped', true
    clearInterval timer

  do @start = ->
    model.set '_stopped', false
    timer = setInterval ->
      model.set '_timer', (((+new Date()) - start) / 1000).toFixed(1)
    , 100
