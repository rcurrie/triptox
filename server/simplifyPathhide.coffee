exports.simplifyPath = (points, tolerance) ->
  Vector = (x, y) ->
    @x = x
    @y = y
  
  Line = (p1, p2) ->
    @p1 = p1
    @p2 = p2
    @distanceToPoint = (point) ->
      m = (@p2.y - @p1.y) / (@p2.x - @p1.x)
      b = @p1.y - (m * @p1.x)
      d = []
      d.push Math.abs(point.y - (m * point.x) - b) / Math.sqrt(Math.pow(m, 2) + 1)
      d.push Math.sqrt(Math.pow((point.x - @p1.x), 2) + Math.pow((point.y - @p1.y), 2))
      d.push Math.sqrt(Math.pow((point.x - @p2.x), 2) + Math.pow((point.y - @p2.y), 2))
      d.sort((a, b) ->
        a - b
      )[0]
  
  douglasPeucker = (points, tolerance) ->
    return [ points[0] ]  if points.length <= 2
    returnPoints = []
    line = new Line(points[0], points[points.length - 1])
    maxDistance = 0
    maxDistanceIndex = 0
    i = 1
    
    while i <= points.length - 2
      distance = line.distanceToPoint(points[i])
      if distance > maxDistance
        maxDistance = distance
        maxDistanceIndex = i
      i++
    if maxDistance >= tolerance
      p = points[maxDistanceIndex]
      line.distanceToPoint p, true
      returnPoints = returnPoints.concat(douglasPeucker(points.slice(0, maxDistanceIndex + 1), tolerance))
      returnPoints = returnPoints.concat(douglasPeucker(points.slice(maxDistanceIndex, points.length), tolerance))
    else
      p = points[maxDistanceIndex]
      line.distanceToPoint p, true
      returnPoints = [ points[0] ]
    returnPoints
  
  arr = douglasPeucker(points, tolerance)
  arr.push points[points.length - 1]
  arr
