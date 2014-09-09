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



# From chrome:
# for(k in CanvasRenderingContext2D.prototype) {
#  if (!CanvasRenderingContext2D.prototype.hasOwnProperty(k)) continue;
#  methods.push(k);
#}
functionNames = ["save", "restore", "scale", "rotate", "translate", "transform",
  "setTransform", "resetTransform", "createLinearGradient",
  "createRadialGradient", "setLineDash", "getLineDash", "clearRect",
  "fillRect", "beginPath", "fill", "stroke", "clip", "isPointInPath",
  "isPointInStroke", "fillText", "strokeText", "measureText", "strokeRect",
  "drawImage", "putImageData", "createPattern", "createImageData",
  "getImageData", "getContextAttributes", "setAlpha", "setCompositeOperation",
  "setLineWidth", "setLineCap", "setLineJoin", "setMiterLimit", "clearShadow",
  "setStrokeColor", "setFillColor", "drawImageFromRect", "setShadow",
  "closePath", "moveTo", "lineTo", "quadraticCurveTo", "bezierCurveTo",
  "arcTo", "rect", "arc", "ellipse"]

properties = ["imageSmoothingEnabled", "webkitImageSmoothingEnabled",
  "fillStyle", "strokeStyle", "textBaseline", "textAlign", "font",
  "lineDashOffset", "shadowColor", "shadowBlur", "shadowOffsetY",
  "shadowOffsetX", "miterLimit", "lineJoin", "lineCap", "lineWidth",
  "globalCompositeOperation", "globalAlpha", "canvas"]

class CanvasProxy
  constructor: (@canvas, opts = {}) ->
    @ctx = canvas.getContext '2d'
    opts.repeat ?= true
    opts.frameDelay ?= 200

    @frames = []
    #@currentFrame = 0

    @buffer = []

    # For reading back - eg ctx.fillStyle = "foo"; console.log(ctx.fillStyle)
    @state = {}

    for fn in functionNames then do (fn) =>
      this[fn] = (args...) =>
        @buffer.push {fn, args}

    for prop in properties then do (prop) =>
      Object.defineProperty this, prop,
        enumerable: yes
        get: =>
          v = @state[prop] if @state
          if v is undefined
            v = @ctx[prop]
          v
        set: (v) =>
          @state[prop] = v if @state
          @buffer.push {prop, v}
  
  commitFrame: ->
    @frames.push @buffer.slice()
    @buffer.length = 0

  playFrame: (i) ->
    requestAnimationFrame =>
      for evt in @frames[i]
        if evt.fn
          @ctx[evt.fn].apply @ctx, evt.args
        else
          @ctx[evt.prop] = evt.v

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
    , delay

  stop: ->
    if @timer
      clearInterval @timer
      @timer = 0


window.canvasProxy = (canvas) -> new CanvasProxy canvas

