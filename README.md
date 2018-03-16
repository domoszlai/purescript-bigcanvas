# purescript-bigcanvas

BigCanvas is (will be) an [infinte canvas](https://en.wikipedia.org/wiki/Infinite_canvas) like
library. 

It is being developed, currently only my experiments are available in the [`experiment`](https://github.com/domoszlai/purescript-bigcanvas/tree/master/experiment) folder. It can be compiled like this:

```bash
$ pulp browserify --src-path experiment --optimise --to bigcanvas-experiment.js
```

You will need a minimal piece of HTML to be able to run it:

```html
<html>
<head>
   <title>The BigCanvas experiment</title>
</head>
<body>
   <canvas id="canvas" width="600" height="600" style="border: 1px solid black;"/>
   <script src="bigcanvas-experiment.js"></script>
</body>
</html>
```

It is also available precompiled, online at http://dlacko.org/bigcanvas/experiment/.
