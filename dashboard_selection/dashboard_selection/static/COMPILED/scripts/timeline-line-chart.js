// Generated by CoffeeScript 1.9.1
var plot_timeline;

plot_timeline = function(studentID, data) {
  d3.json(data, function(activities) {
    var render;
    render = function() {
      var activity, changeSiblingGuideOpacity, createLine, days, duration, getHlineType, getTimelineTypeSuffix, height, hlineG, line, lineChartHeight, numDays, perdayThreshold, rectSide, selector, svg, togglePerDayReference, tooltip, update, width, y;
      changeSiblingGuideOpacity = function(node, val) {
        d3.select(node.parentNode).select(".tl-guide").attr("opacity", val);
      };
      line = function(label) {
        return d3.svg.line().x(function(d, i) {
          return (i + 0.5) * rectSide;
        }).y(function(d) {
          return y(d[label]);
        }).interpolate("step-after");
      };
      createLine = function(selection, label) {
        var lineGen;
        lineGen = line(label + getTimelineTypeSuffix());
        selection.append("path").attr("d", lineGen(activity)).attr("class", label + "-line");
      };
      getTimelineTypeSuffix = function() {
        if (d3.select("#select-timelinetype").property("value") === "accumulated") {
          return "";
        } else {
          return "PerDay";
        }
      };
      getHlineType = function(val) {
        if (val % 60 === 0) {
          return "certificate";
        } else {
          return "reference";
        }
      };
      togglePerDayReference = function(selection) {
        selection.selectAll(".perday").attr("display", function(d) {
          if (getTimelineTypeSuffix() === "") {
            return "none";
          } else {
            return "auto";
          }
        });
      };
      tooltip = function(selection) {
        var p, positionTooltip, rootSelection, tooltipDiv;
        positionTooltip = function() {
          var mousePosition;
          mousePosition = d3.mouse(rootSelection.node());
          tooltipDiv.style({
            left: (mousePosition[0] + 10) + "px",
            top: (mousePosition[1] - 40) + "px"
          });
        };
        p = function(d, c) {
          if (c) {
            return "<p class=\"tooltip-" + c + "\"> " + d + " </p>";
          } else {
            return "<p>" + d + "</p>";
          }
        };
        rootSelection = d3.select("body");
        tooltipDiv = void 0;
        selection.on("mouseover.tooltip", function(d, i) {
          var labelSuffix, whetherActive;
          rootSelection.selectAll("div.tooltip").remove();
          labelSuffix = getTimelineTypeSuffix();
          tooltipDiv = rootSelection.append("div").attr("class", "tooltip");
          positionTooltip();
          whetherActive = (d.active === 1 ? "active" : "inactive");
          tooltipDiv.html(p(d.date) + p(whetherActive.toUpperCase(), whetherActive) + p("Problem: " + (d['problem' + labelSuffix].toFixed(1)), "problem") + p("Video: " + (d['video' + labelSuffix].toFixed(1)), "video"));
        }).on("mousemove.tooltip", function() {
          positionTooltip();
        }).on("mouseout.tooltip", function() {
          tooltipDiv.remove();
        });
      };
      selector = d3.select("#timeline");
      width = selector[0][0].offsetWidth;
      height = (d3.select(window)[0][0].outerWidth >= 1000 ? d3.select("#progress")[0][0].offsetHeight - 360 : width / 2);
      selector.selectAll("svg").remove();
      studentID = d3.select("#select-student").property("value");
      svg = selector.append("svg").attr("width", width).attr("height", height);
      activity = activities[studentID];
      numDays = activity.length;
      rectSide = width / numDays;
      lineChartHeight = height - rectSide;
      duration = 1000;
      perdayThreshold = 20;
      y = d3.scale.linear().range([lineChartHeight, 0]);
      y = y.domain([0, (getTimelineTypeSuffix() === "" ? 100 : perdayThreshold)]);
      days = svg.selectAll(".tl-day").data(activity).enter().append("g").attr("class", "tl-day");
      days.append("rect").attr("width", rectSide).attr("height", rectSide).attr("x", function(d, i) {
        return i * rectSide;
      }).attr("y", lineChartHeight).attr("class", function(d) {
        if (d.active === 1) {
          return "tl-active";
        } else {
          return "tl-inactive";
        }
      });
      days.append("rect").attr("width", rectSide).attr("height", lineChartHeight).attr("x", function(d, i) {
        return i * rectSide;
      }).attr("class", function(d) {
        if (d.active === 1) {
          return "tl-active tl-guide";
        } else {
          return "tl-inactive tl-guide";
        }
      }).attr("opacity", 0);
      days.selectAll("rect").on("mouseover", function() {
        changeSiblingGuideOpacity(this, 0.5);
      }).on("mouseout", function() {
        changeSiblingGuideOpacity(this, 0);
      }).call(tooltip);
      ["video", "problem"].forEach(function(label) {
        svg.call(createLine, label);
      });
      hlineG = svg.selectAll(".reference").data([perdayThreshold / 2, perdayThreshold, 50, 100, 60]).enter().append("g").attr("class", "reference");
      hlineG.append("line").attr("x1", 0.5 * rectSide).attr("y1", function(d) {
        return y(d);
      }).attr("x2", (numDays - 0.5) * rectSide).attr("y2", function(d) {
        return y(d);
      }).attr("class", function(d) {
        return (getHlineType(d)) + "-line";
      }).classed("perday", function(d) {
        return d <= perdayThreshold;
      });
      hlineG.append("text").attr("x", 0.5 * rectSide).attr("y", function(d) {
        return y(d);
      }).attr("class", function(d) {
        return (getHlineType(d)) + "-text";
      }).classed("perday", function(d) {
        return d <= perdayThreshold;
      }).text(function(d) {
        if (d % 60 !== 0) {
          return d + "%";
        } else {
          return d + "% Certification";
        }
      });
      hlineG.call(togglePerDayReference);
      svg.append("rect").attr("x", -1 * width).attr("y", -1 * height).attr("height", height).attr("width", width).attr("class", "curtain").attr("transform", "rotate(180)").transition().duration(duration).attr("width", 0);
      update = function() {
        y = y.domain([0, (getTimelineTypeSuffix() === "" ? 100 : perdayThreshold)]);
        hlineG.selectAll("text").transition().attr("y", function(d) {
          return y(d);
        });
        hlineG.selectAll("line").transition().attr("y1", function(d) {
          return y(d);
        }).attr("y2", function(d) {
          return y(d);
        });
        hlineG.call(togglePerDayReference);
        ["video", "problem"].forEach(function(label) {
          var lineGen;
          lineGen = line(label + getTimelineTypeSuffix());
          d3.selectAll("path." + label + "-line").transition().attr("d", lineGen(activity));
        });
      };
      d3.select("#select-timelinetype").on("change", update);
    };
    render();
    d3.select(window).on("resize.timeline", render);
    d3.select("#select-student").on("change.timeline", render);
  });
};
