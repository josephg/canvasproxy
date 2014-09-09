This is a simple web module for syncronously making simple repeating canvas
based animations.

I wrote this because I wanted to programatically render an animated gif for an
example, but its way simpler to just buffer canvas drawing calls and render
them.

# Usage

```javascript
var canvas = document.getElementById("mycanvas");
canvas.width = 320;
canvas.height = 240;

ctx = canvasProxy(canvas)
ctx.fillStyle = 'red';
ctx.fillRect(0, 0, 320, 240);
ctx.commitFrame();
ctx.fillStyle = 'green';
ctx.fillRect(0, 0, 320, 240);
ctx.commitFrame();
ctx.fillStyle = 'blue';
ctx.fillRect(0, 0, 320, 240);
ctx.commitFrame();

ctx.play(300, true);
```

