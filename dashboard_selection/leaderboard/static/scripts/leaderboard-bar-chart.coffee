plot_leaderboard = (student_id, top_data) ->

  # highlight oneself
  highlightOneself = (selection) ->
    selection.classed("lb-oneself", (d) ->
       d.user == student_id
    )
    return
  reformatScoreByLabel = (val, label) ->
    switch label
       when "score_rating"
          val + " points"
  #     when "top10_active"
  #        val + "days"
  #     when "top10_timespent"
  #        Math.round(val / 60) + "h" + (val % 60) + "min"
  labelToClassName = (label) -> "lb-" + label.replace("_", "-")
  labelToTitleText =
    "score_rating": "Score rating"

  # init table
  table = d3.select("#leaderboard")
    .append("table")
    .attr("width", "100%")
    .attr("height", "192px") # fixed height for proper position on small screen

  render = ->
     table.selectAll("*").remove()
     width = table[0][0].offsetWidth
     rankWidth = width / 10
     nameWidth = rankWidth * 4
     barWidth = rankWidth * 5
     label = d3.select("#select-top10")
        .property("value")
     rows = table.selectAll("tr")
        .data(top_data[label])
     rows.enter()
        .append "tr"

     # add ranks
     rows.append("td")
        .attr("class", "text-ranks")
        .attr("width", rankWidth).text((d) -> "# #{ d.rating}")


     # add student names
     rows.append("td")
        .attr("class", "text-student-names")
        .attr("width", 0)
        .style("opacity", 0)
        .transition()
        .duration(500)
        .attr("width", nameWidth)
        .style("opacity", 1).text((d) -> "#{d.first_name} #{d.last_name}")

     # scaler for bars
     scaler = d3.scale
        .linear()
        .domain([0, top_data[label][0].value])
        .range([0, barWidth])

     # add bars
     rows.append("td")
        .attr("width", barWidth)
        .attr("class", "text-scores")
        .append("div").style("width", 0)
        .transition().duration(1000)
        .style("width", (d) -> scaler(d.value) + "px")
        .attr("class", labelToClassName(label)).text((d) ->
           reformatScoreByLabel d.value, label
        )

     rows.exit().remove()
     rows.selectAll("td")
        .call(highlightOneself)
     return

  # init selectbox options
  d3.select("#select-top10")
     .selectAll("option")
     .data([
        "score_rating"
     ]).enter()
     .append("option")
     .attr("value", (d) -> d)
     .text((d) -> labelToTitleText[d])

  render()

  # rerender when window-size or select-option changes
  d3.select(window).on("resize", render)
  d3.select("#leaderboard").on("change", render)

  return


