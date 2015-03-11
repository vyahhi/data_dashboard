plot_progress = (studentID) ->

   # build up skeleton for rendering
   selector = d3.select("#progress")
   svgSide = selector[0][0].offsetWidth
   r = svgSide * 4 / 9
   bandWidth = r / 4

   # init responsive svg
   rootG = selector.append("svg").attr("width", "100%").attr("height", "100%").attr("viewBox", "0 0 " + svgSide + " " + svgSide).attr("preserveAspectRatio", "xMinYMin").append("g").attr("transform", "translate(" + svgSide / 2 + "," + svgSide / 2 + ")")

   # init an equally segmented pie layout
   pie = d3.layout.pie().value(->
      1
   )

   # color scale for peer comparison
   color = d3.scale.linear()
      .domain([-1, 0, 1])
      .range(["#D9321D", "#FFF", "#45D91D"])

   # init default report group
   defaultReportG = rootG.append("g").attr("class", "default-report")

   # clickable area and help text for going back
   backG = rootG.append("g")
      .attr("class", "go-back")
   backG.append("circle")
      .attr("r", r - bandWidth)
      .attr("opacity", 0)
   helpText = backG.append("text")
      .attr("transform", "translate(0," + (-bandWidth * 2.5) + ")")
      .attr("opacity", 0)
      .attr("class", "back-button")
      .text("<")
   d3.json "/data/structure.json", (structure) ->
      d3.json "/data/students.json", (data) ->

         render = (label, isFGNotAnimated) ->
            # animation helpers
            showPercentage = (selection, val, isNotAnimated) ->
               if isNotAnimated
                  selection.text(valToPercentString(val))
               else
                  selection.text("0%")
                  .transition()
                  .duration(durationNormal)
                  .tween("text", ->
                     i = d3.interpolate(0, val)
                     return (t) -> @textContent = valToPercentString(i(t))

                  )

               return

            showArcsFG = (selection, isNotAnimated) ->
               if isNotAnimated
                  selection.attr "d", arcFG
               else # foreground arcs transite from outerRadius to innerRadius
                  selection.attr("d", d3.svg.arc().innerRadius(r).outerRadius(r))
                     .transition()
                     .duration(durationNormal)
                     .attrTween("d", (d) ->
                        dStart = JSON.parse(JSON.stringify(d))
                        d.data = 0
                        i = d3.interpolateObject(d, dStart)
                        return (t) -> arcFG(i(t))
                     )
               return

            slideOut = (selection, translation) ->
               selection.attr("opacity", 0)
                  .transition()
                  .delay((if isFGNotAnimated then 0 else durationNormal))
                  .duration(durationShort)
                  .attr("transform", "translate(" + translation + ")")
                  .attr("opacity", 1)
               return

            hideToArcCentroid = (selection) ->
               selection.attr("transform", (d) ->
                  xy = arcBG.centroid(d)
                  "translate(" + xy[0] + "," + xy[1] + ") " + "scale(0.1)"
               ).attr "opacity", 0
               return

            hideToArcCentroidAnimated = (selection) ->
               selection.transition()
                  .duration(durationShort)
                  .call(hideToArcCentroid)
               return

            showArcReport = (selection, translation) ->
               selection.transition()
                  .duration(durationShort)
                  .attr("transform", "translate(" + translation + ") " + "scale(1)")
                  .attr("opacity", 1)
               return

            arcHover = (arcNode, opacityArc, opacityDefaultReport, opacityArcReport) ->
               currentSelector = d3.select(arcNode)
                  .attr("opacity", opacityArc)
               currentSelector.select(".arc-comparison")
                  .attr("opacity", opacityArcReport)
               defaultReportG.selectAll("text")
                  .transition()
                  .duration(durationShort)
                  .attr("opacity", opacityDefaultReport)
               if opacityArcReport is 1
                  currentSelector.select(".report-title")
                     .call showArcReport, "0," + (bandWidth * -1.5)
                  currentSelector.select(".report-comparison")
                     .call showArcReport, "0," + (bandWidth * 1.5)
                  currentSelector.select(".percentage")
                     .call showArcReport, "0,0"
               else
                  currentSelector.selectAll("text")
                     .call(hideToArcCentroidAnimated)
               return

            donut = studentData.donut[label]
            donutAvg = peerData.donut[label]
            report = studentData.report[label]
            reportAvg = peerData.report[label]
            durationNormal = 1000
            durationShort = durationNormal / 2

            # if donut is array then generate default report, else then clear chart
            if donut and donut.constructor is Array
               # remove old report
               defaultReportG.selectAll("text").remove()

               # default report - title
               defaultReportG.append("text")
                  .attr("transform", "translate(0," + (-bandWidth * 1.5) + ")")
                  .attr("class", "report-title")
                  .text(label.toUpperCase())

               # default report - percentage (for both exercise and video)
               defaultReportG.append("text")
                  .attr("class", "percentage")
                  .classed("category-" + category, true)
                  .call(showPercentage, report, isFGNotAnimated)

               # default report - peer comparison
               diff = report - reportAvg
               defaultReportG.append("text")
                  .attr("class", "report-comparison")
                  .text(generateComparisonText(diff))
                  .attr("fill", color(darkerRange(diff)))
                  .call(slideOut, "0," + bandWidth * 1.5)
            else
               donut = []

            # init arc groups
            arcs = rootG.selectAll(".arc")
               .data(pie(donut)) # get angles from pie layout
            arcs.enter()
               .append("g")
               .attr("class", "arc")

            # background arcs
            arcBG = d3.svg.arc()
               .innerRadius(r - bandWidth)
               .outerRadius(r)
            arcs.append("path")
               .attr("class", "arc-bg")
               .attr("d", arcBG)

            # foreground arcs for visualize current progress
            arcFG = d3.svg.arc()
               .innerRadius((d) -> r - d.data * bandWidth)
               .outerRadius(r)
            arcs.append("path").attr("class", "arc-fg").classed("category-" + category, true).call showArcsFG, isFGNotAnimated

            # colored outer arcs for peer comparison
            arcComparison = d3.svg.arc()
               .innerRadius(r)
               .outerRadius(r + bandWidth * 0.1)
            arcs.append("path")
               .attr("class", "arc-comparison")
               .attr("opacity", 0)
               .attr("fill", (d, i) -> color(darkerRange(d.data - donutAvg[i])))
               .attr("d", arcComparison)

            # arc report
            arcs.append("text")
               .call(hideToArcCentroid) #"translate(0,0)"
               .attr("class", "report-title")
               .text((d, i) -> structure.getChildren(label)[i].toUpperCase())

            # arc report - percentage
            arcs.append("text")
               .call(hideToArcCentroid)
               .attr("class", "percentage")
               .classed("category-" + category, true)
               .text((d) -> valToPercentString d.data)

            # arc report - peer comparison
            arcs.append("text")
               .call(hideToArcCentroid)
               .attr("class", "report-comparison")
               .attr("fill", (d, i) -> color darkerRange(d.data - donutAvg[i]))
               .text((d, i) -> generateComparisonText d.data - donutAvg[i])

            # clear old data
            arcs.exit().remove()

            # rerender when chart options change
            d3.select("#select-category").on("change", ->
               category = @value
               studentData = data.getStudentData(studentID)
               update(label)
               return
            )

            ###
            d3.select("#select-student").on("change", ->
               studentID = @value
               studentData = data.getStudentData(studentID)
               update(label)
               return
            )
            ###

            d3.select("#select-peer").on("change", ->
               peerType = @value
               peerData = data.getPeerData(peerType)
               update(label, true)
               return
            )

            # show corresponding report & highlight hovered arc when hovering an arc *path*
            arcs.on("mouseover", ->
               arcHover(this, 0.7, 0, 1)
               return
            ).on("mouseout", ->
               arcHover(this, 1, 1, 0)
               return
            )

            # postpone mouseover events after default-report transition
            arcs.attr("pointer-events", "none")
               .transition()
               .duration(durationNormal + durationShort * 1.5)
               .transition()
               .attr("pointer-events", "auto")

            # zoom in when clicking an arc
            arcs.on "click", (d, i) ->
               structure.checkThenRun(structure.getChildren(label)[i])(update)
               return

            # show help text for going back when hovering inner circle and being able to go back
            backG.on("mouseover", ->
               structure.checkThenRun(structure.getParent(label))(showHelpText)
               return
            ).on("mouseout", hideHelpText)

            # zoom out when clicking inner circle
            backG.on("click", ->
               structure.checkThenRun(structure.getParent(label))(update)
               return
            )

            return

         # helpers
         update = (label, isFGNotAnimated) ->
            render null # clean previous data to avoid data collision
            render label, isFGNotAnimated
            hideHelpText()  if label is "overall"
            return

         hideHelpText = ->
            helpText.attr "opacity", 0

         showHelpText = ->
            helpText.attr "opacity", 0.2

         valToPercentString = (val) ->
            "#{ Math.abs(Math.floor(val * 100)) }%"

         generateComparisonText = (val) ->
            (if val >= 0 then valToPercentString(val) + " ahead of peers" else valToPercentString(val) + " behind peers")

         darkerRange = (val) ->
            (if val >= 0 then val / 2 + 0.5 else val / 2 - 0.5)

         isStudentID = (str) -> not isNaN(str)

         isPeerType = (str) -> isNaN(str) and str.indexOf("get") < 0

         peerTypeToTitleText =
            "avg": "all students"
            "top10_problem": "10 students completed most problems"
            "top10_video": "10 students completed most videos"
            "top10_active": "10 most active students"
            "top10_timespent": "10 students spent most time"

         # add some helper methods for data objects
         structure.getParent = (label) ->
            this[category].parent[label]

         structure.getChildren = (label) ->
            this[category].children[label]

         structure.checkThenRun = (label) ->
            # if label is a possible level, then run nextstep function, else then do nothing
            if label of this[category].children
               (nextstep) ->
                  nextstep(label)
            else
               (nextstep) -> return

         data.getIDs = (filter) ->
            Object.keys(this).filter(filter)

         data.getPeerData = (peerType) ->
            this[peerType][category]

         data.getStudentData = (id) ->
            this[id][category]

         # init selectbox for peer type
         d3.select("#select-peer")
            .selectAll("option")
            .data(data.getIDs(isPeerType).sort())
            .enter()
            .append("option")
            .attr("value", (d) ->
               d
            ).text((d) -> peerTypeToTitleText[d])

         category = d3.select("#select-category").property("value")
         #studentID = d3.select("#select-student").property("value")
         peerType = d3.select("#select-peer").property("value")
         studentData = data.getStudentData(studentID)
         peerData = data.getPeerData(peerType)


         # rendering starts from 'overall' level
         render("overall")
         return

      return

   return
