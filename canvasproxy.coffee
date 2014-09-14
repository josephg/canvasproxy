# API:
#
# canvas = ...
#
# ctx = canvasProxy(canvas)
# ctx.fillStyle = 'red';
# ctx.fillRect(0, 0, 320, 240);
# ctx.commitFrame()
# ctx.fillStyle = 'green';
# ctx.fillRect(0, 0, 320, 240);
# ctx.commitFrame()
# ctx.fillStyle = 'blue';
# ctx.fillRect(0, 0, 320, 240);
# ctx.commitFrame()
#
# ctx.play frameDelay:200, repeat:1000
#

class CanvasProxy
  constructor: (canvas) ->
    @ctx = canvas.getContext '2d'

    @frames = []
    #@currentFrame = 0

    @buffer = []

    # For reading back - eg ctx.fillStyle = "foo"; console.log(ctx.fillStyle)
    @state = {}

    @_addProp(k,v) for k,v of @ctx
 
  _addProp: (k, v) ->
    if typeof v is 'function'
      this[k] = => @buffer.push {fn:k, args:arguments}
    else
      Object.defineProperty this, k,
        enumerable: yes
        get: ->
          v = @state[k] if @state
          if v is undefined
            v = @ctx[k]
          v
        set: (v) ->
          @state[k] = v if @state
          @buffer.push {prop:k, v}
    return

  commitFrame: ->
    @frames.push @buffer
    @buffer = []

  playFrame: (i) ->
    requestAnimationFrame =>
      for evt in @frames[i]
        if evt.fn
          @ctx[evt.fn].apply @ctx, evt.args
        else
          @ctx[evt.prop] = evt.v
      return

  play: (delay = 200, repeat = yes) ->
    @state = null # Instead direct get() calls to the context itself.

    # No frames - nothing to do!
    return if @frames.length is 0

    @stop()

    # Play the first frame immediately.
    @playFrame 0
    @pos = 1

    @timer = setInterval =>
      @playFrame @pos++
      if @pos >= @frames.length
        if repeat
          @pos = 0
        else
          @stop()
      return
    , delay

  stop: ->
    if @timer
      clearInterval @timer
      @timer = 0


window.canvasProxy = (canvas) -> new CanvasProxy canvas

