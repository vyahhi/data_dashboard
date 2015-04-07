plot_timeline = (studentID, activities_data) ->
    render = ->

       changeSiblingGuideOpacity = (node, val) ->
          d3.select(node.parentNode)
          .select(".tl-guide")
          .attr("opacity", val)
          return
       line = (label) ->
          d3.svg.line().x((d, i) -> (i + 0.5) * rectSide)
          .y((d) -> y(d[label]))
          .interpolate("step-after")
       createLine = (selection, label) ->
          lineGen = line(label + getTimelineTypeSuffix())
          selection.append("path")
          .attr("d", lineGen(activity))
          .attr("class", "#{label}-line")
          return

       getTimelineTypeSuffix = ->
          (if d3.select("#select-timelinetype").property("value") is "accumulated" then "" else "PerDay")

       getHlineType = (val) ->
          (if val % 60 is 0 then "certificate" else "reference")

       togglePerDayReference = (selection) ->
          selection.selectAll(".perday").attr "display", (d) ->
             (if getTimelineTypeSuffix() is "" then "none" else "auto")
          return

       tooltip = (selection) ->
          # clean up lost tooltips
          positionTooltip = ->
             mousePosition = d3.mouse(rootSelection.node())
             tooltipDiv.style
                left: "#{ mousePosition[0] + 10 }px"
                top: "#{ mousePosition[1] - 40 }px"
             return

          p = (d, c) ->
             (if c then "<p class=\"tooltip-#{ c }\"> #{d} </p>" else "<p>#{ d }</p>")
          rootSelection = d3.select("body")
          tooltipDiv = undefined

          selection.on("mouseover.tooltip", (d, i) ->
             rootSelection.selectAll("div.tooltip").remove()
             labelSuffix = getTimelineTypeSuffix()
             tooltipDiv = rootSelection.append("div")
             .attr("class", "tooltip")
             positionTooltip()
             whetherActive = (if d.active is 1 then "active" else "inactive")
             tooltipDiv.html(p(d.date) +
                p(whetherActive.toUpperCase(), whetherActive) +
                p("Problem: #{ d['problem' + labelSuffix].toFixed(1) }", "problem") +
                p("Video: #{ d['video' + labelSuffix].toFixed(1) }", "video"))
             return
          ).on("mousemove.tooltip", ->
             positionTooltip()
             return
          ).on("mouseout.tooltip", ->
             tooltipDiv.remove()
             return
          )

          return

       selector = d3.select("#timeline")
       width = selector[0][0].offsetWidth
       height = (if d3.select(window)[0][0].outerWidth >= 1000 then d3.select("#progress")[0][0].offsetHeight - 300 else width / 2)

       selector.selectAll("svg").remove()

       # init responsive svg
       svg = selector.append("svg")
          .attr("width", width)
          .attr("height", height)
       activity = activities_data[studentID]
       numDays = activity.length
       rectSide = width / numDays
       lineChartHeight = height - rectSide
       duration = 1000
       perdayThreshold = 20
       y = d3.scale.linear().range([lineChartHeight, 0])
       y = y.domain([
          0
          (if getTimelineTypeSuffix() is "" then 100 else perdayThreshold)
       ])
       days = svg.selectAll(".tl-day")
          .data(activity)
          .enter()
          .append("g")
          .attr("class", "tl-day")

       # days punch card
       days.append("rect")
          .attr("width", rectSide)
          .attr("height", 7)
          .attr("x", (d, i) -> i * rectSide)
          .attr("y", lineChartHeight)
          .attr("class", (d) ->
             (if d.active is 1 then "tl-active" else "tl-inactive")
          )

       # days guide column
       days.append("rect")
          .attr("width", rectSide)
          .attr("height", lineChartHeight)
          .attr("x", (d, i) -> i * rectSide)
          .attr("class", (d) ->
             (if d.active is 1 then "tl-active tl-guide" else "tl-inactive tl-guide")
          ).attr("opacity", 0)

       # hover effect for days
       days.selectAll("rect").on("mouseover", ->
             changeSiblingGuideOpacity(this, 0.5)
             return
          ).on("mouseout", ->
             changeSiblingGuideOpacity(this, 0)
             return
          ).call(tooltip)

       # add lines
       ["video", "problem"].forEach((label) ->
          svg.call(createLine, label)
          return
       )

       # add horizontal lines
       hlineG = svg.selectAll(".reference")
          .data([
             perdayThreshold / 2
             perdayThreshold
             50
             100
             60
          ]).enter()
          .append("g")
          .attr("class", "reference")

       hlineG.append("line")
          .attr("x1", 0.5 * rectSide)
          .attr("y1", (d) -> y(d))
          .attr("x2", (numDays - 0.5) * rectSide)
          .attr("y2", (d) -> y(d))
          .attr("class", (d) -> "#{ getHlineType(d) }-line")
          .classed("perday", (d) -> d <= perdayThreshold)

       hlineG.append("text")
          .attr("x", 0.5 * rectSide)
          .attr("y", (d) -> y(d))
          .attr("class", (d) -> "#{ getHlineType(d) }-text")
          .classed("perday", (d) -> d <= perdayThreshold)
          .text((d) ->
             (if d % 60 isnt 0 then "#{ d }%" else "#{ d }% Certification")
          )

       hlineG.call(togglePerDayReference)

       # curtain animation
       svg.append("rect")
          .attr("x", -1 * width)
          .attr("y", -1 * height)
          .attr("height", height)
          .attr("width", width)
          .attr("class", "curtain")
          .attr("transform", "rotate(180)")
          .transition()
          .duration(duration)
          .attr("width", 0)

       update = ->

          # update y scale
          y = y.domain([
             0
             (if getTimelineTypeSuffix() is "" then 100 else perdayThreshold)
          ])

          # update reference lines height
          hlineG.selectAll("text")
             .transition()
             .attr("y", (d) -> y(d))

          hlineG.selectAll("line")
             .transition()
             .attr("y1", (d) -> y(d))
             .attr("y2", (d) -> y(d))

          hlineG.call(togglePerDayReference)

          # update timelines
          (["video", "problem"]).forEach((label) ->
             lineGen = line(label + getTimelineTypeSuffix())
             d3.selectAll("path.#{label}-line")
                .transition()
                .attr("d", lineGen(activity))
             return
          )

          return


       # transition between accumulated and perday data
       d3.select("#select-timelinetype")
          .on("change", update)
       return

    render()

    d3.select(window)
       .on("resize.timeline", render)
    d3.select("#select-student").on "change.timeline", render

    return

