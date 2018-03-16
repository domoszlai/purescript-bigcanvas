# The BigCanvas experiment

This is the expirement I conducted to find out how could the BigCanvas PureScript module implemented. For explanation, please read the original article at http://dlacko.org/blog/2018/03/16/purescript-canvas-event-handling-with-state/.

The sample code can be compiled like this (from the root folder):

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
