$.widget 'custom.infographicSphere',
  options:
    velocity: [.01, .01]
    strokeStyle: 'red'
    lineWidth: 0.5
    backsideVisible: true
    subdivision: 5
    scaleHeight: 0.33
    height: window.innerHeight
    width: window.innerWidth

  _create: ->
    @timeZero = Date.now()
    elId = @element.attr('id')
    @projection = d3.geo.orthographic().scale(@options.height * @options.scaleHeight)
    @canvas = d3.select("##{elId}").append('canvas')
    @context = @canvas.node().getContext('2d')

    @setOptions()
    d3.timer(@timerFunc())

  _init: ->

  timerFunc: ->
    time = Date.now() - @timeZero
    @projection.rotate([time * @options.velocity[0], time * @options.velocity[1]])
    @geodesic @context, @options.subdivision, @projection

  setOptions: ->
    @canvas.attr('width', @options.width)
      .attr('height', @options.height)
    @context.strokeStyle = @options.strokeStyle
    @context.lineWidth = @options.lineWidth

  geodesic: (surface, subdivision, size) ->
    @faces = d3.geodesic.polygons(subdivision).map (d) ->
      d = d.coordinates[0]
      d.pop # use an open polygon
      d.fill = d3.hsl(d[0][0], 1, .5) # rainbow fill
      d.polygon = d3.geom.polygon(d.map(size))
      d

    @redraw(surface, size)

  redraw: (surface, size) ->
    surface.clearRect(0, 0, @width, @height)

    @faces.forEach (d) =>
      d.polygon[0] = size d[0]
      d.polygon[1] = size d[1]
      d.polygon[2] = size d[2]

      if d.visible = d.polygon.area() > 0
        surface.beginPath()
        @drawTriangle(surface, d.polygon)

    surface.beginPath()

    @faces.forEach (d) =>
      @drawTriangle(surface, d.polygon)

    surface.stroke()

  drawTriangle: (surface, triangle) ->
    surface.moveTo triangle[0][0], triangle[0][1]
    surface.lineTo triangle[1][0], triangle[1][1]
    surface.lineTo triangle[2][0], triangle[2][1]
    surface.closePath()
