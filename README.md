# purescript-bigcanvas

BigCanvas is (will be) an [infinte canvas](https://en.wikipedia.org/wiki/Infinite_canvas) like
library. 

It is being developed, currently only my experiments are available in the [experiment](https://github.com/domoszlai/purescript-bigcanvas/tree/master/experiment) folder. It can be compiled as:

```bash
$ pulp browserify --src-path experiment --optimise --to bigcanvas-experiment.js
```

You will need a minimal piece of HTML to be able to run it:

```html
<html>
<head>
</head>
<body>
</body>
</html>
```

It is also available online at http://dlacko.org/bigcanvas/experiment/.