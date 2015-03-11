// Generated by CoffeeScript 1.9.1
var plot_progress;

plot_progress = function(studentID) {
  var backG, bandWidth, color, defaultReportG, helpText, pie, r, rootG, selector, svgSide;
  selector = d3.select("#progress");
  svgSide = selector[0][0].offsetWidth;
  r = svgSide * 4 / 9;
  bandWidth = r / 4;
  rootG = selector.append("svg").attr("width", "100%").attr("height", "100%").attr("viewBox", "0 0 " + svgSide + " " + svgSide).attr("preserveAspectRatio", "xMinYMin").append("g").attr("transform", "translate(" + svgSide / 2 + "," + svgSide / 2 + ")");
  pie = d3.layout.pie().value(function() {
    return 1;
  });
  color = d3.scale.linear().domain([-1, 0, 1]).range(["#D9321D", "#FFF", "#45D91D"]);
  defaultReportG = rootG.append("g").attr("class", "default-report");
  backG = rootG.append("g").attr("class", "go-back");
  backG.append("circle").attr("r", r - bandWidth).attr("opacity", 0);
  helpText = backG.append("text").attr("transform", "translate(0," + (-bandWidth * 2.5) + ")").attr("opacity", 0).attr("class", "back-button").text("<");
  d3.json("/data/structure.json", function(structure) {
    d3.json("/data/students.json", function(data) {
      var category, darkerRange, generateComparisonText, hideHelpText, isPeerType, isStudentID, peerData, peerType, peerTypeToTitleText, render, showHelpText, studentData, update, valToPercentString;
      render = function(label, isFGNotAnimated) {
        var arcBG, arcComparison, arcFG, arcHover, arcs, diff, donut, donutAvg, durationNormal, durationShort, hideToArcCentroid, hideToArcCentroidAnimated, report, reportAvg, showArcReport, showArcsFG, showPercentage, slideOut;
        showPercentage = function(selection, val, isNotAnimated) {
          if (isNotAnimated) {
            selection.text(valToPercentString(val));
          } else {
            selection.text("0%").transition().duration(durationNormal).tween("text", function() {
              var i;
              i = d3.interpolate(0, val);
              return function(t) {
                return this.textContent = valToPercentString(i(t));
              };
            });
          }
        };
        showArcsFG = function(selection, isNotAnimated) {
          if (isNotAnimated) {
            selection.attr("d", arcFG);
          } else {
            selection.attr("d", d3.svg.arc().innerRadius(r).outerRadius(r)).transition().duration(durationNormal).attrTween("d", function(d) {
              var dStart, i;
              dStart = JSON.parse(JSON.stringify(d));
              d.data = 0;
              i = d3.interpolateObject(d, dStart);
              return function(t) {
                return arcFG(i(t));
              };
            });
          }
        };
        slideOut = function(selection, translation) {
          selection.attr("opacity", 0).transition().delay((isFGNotAnimated ? 0 : durationNormal)).duration(durationShort).attr("transform", "translate(" + translation + ")").attr("opacity", 1);
        };
        hideToArcCentroid = function(selection) {
          selection.attr("transform", function(d) {
            var xy;
            xy = arcBG.centroid(d);
            return "translate(" + xy[0] + "," + xy[1] + ") " + "scale(0.1)";
          }).attr("opacity", 0);
        };
        hideToArcCentroidAnimated = function(selection) {
          selection.transition().duration(durationShort).call(hideToArcCentroid);
        };
        showArcReport = function(selection, translation) {
          selection.transition().duration(durationShort).attr("transform", "translate(" + translation + ") " + "scale(1)").attr("opacity", 1);
        };
        arcHover = function(arcNode, opacityArc, opacityDefaultReport, opacityArcReport) {
          var currentSelector;
          currentSelector = d3.select(arcNode).attr("opacity", opacityArc);
          currentSelector.select(".arc-comparison").attr("opacity", opacityArcReport);
          defaultReportG.selectAll("text").transition().duration(durationShort).attr("opacity", opacityDefaultReport);
          if (opacityArcReport === 1) {
            currentSelector.select(".report-title").call(showArcReport, "0," + (bandWidth * -1.5));
            currentSelector.select(".report-comparison").call(showArcReport, "0," + (bandWidth * 1.5));
            currentSelector.select(".percentage").call(showArcReport, "0,0");
          } else {
            currentSelector.selectAll("text").call(hideToArcCentroidAnimated);
          }
        };
        donut = studentData.donut[label];
        donutAvg = peerData.donut[label];
        report = studentData.report[label];
        reportAvg = peerData.report[label];
        durationNormal = 1000;
        durationShort = durationNormal / 2;
        if (donut && donut.constructor === Array) {
          defaultReportG.selectAll("text").remove();
          defaultReportG.append("text").attr("transform", "translate(0," + (-bandWidth * 1.5) + ")").attr("class", "report-title").text(label.toUpperCase());
          defaultReportG.append("text").attr("class", "percentage").classed("category-" + category, true).call(showPercentage, report, isFGNotAnimated);
          diff = report - reportAvg;
          defaultReportG.append("text").attr("class", "report-comparison").text(generateComparisonText(diff)).attr("fill", color(darkerRange(diff))).call(slideOut, "0," + bandWidth * 1.5);
        } else {
          donut = [];
        }
        arcs = rootG.selectAll(".arc").data(pie(donut));
        arcs.enter().append("g").attr("class", "arc");
        arcBG = d3.svg.arc().innerRadius(r - bandWidth).outerRadius(r);
        arcs.append("path").attr("class", "arc-bg").attr("d", arcBG);
        arcFG = d3.svg.arc().innerRadius(function(d) {
          return r - d.data * bandWidth;
        }).outerRadius(r);
        arcs.append("path").attr("class", "arc-fg").classed("category-" + category, true).call(showArcsFG, isFGNotAnimated);
        arcComparison = d3.svg.arc().innerRadius(r).outerRadius(r + bandWidth * 0.1);
        arcs.append("path").attr("class", "arc-comparison").attr("opacity", 0).attr("fill", function(d, i) {
          return color(darkerRange(d.data - donutAvg[i]));
        }).attr("d", arcComparison);
        arcs.append("text").call(hideToArcCentroid).attr("class", "report-title").text(function(d, i) {
          return structure.getChildren(label)[i].toUpperCase();
        });
        arcs.append("text").call(hideToArcCentroid).attr("class", "percentage").classed("category-" + category, true).text(function(d) {
          return valToPercentString(d.data);
        });
        arcs.append("text").call(hideToArcCentroid).attr("class", "report-comparison").attr("fill", function(d, i) {
          return color(darkerRange(d.data - donutAvg[i]));
        }).text(function(d, i) {
          return generateComparisonText(d.data - donutAvg[i]);
        });
        arcs.exit().remove();
        d3.select("#select-category").on("change", function() {
          var category, studentData;
          category = this.value;
          studentData = data.getStudentData(studentID);
          update(label);
        });

        /*
        d3.select("#select-student").on("change", ->
           studentID = @value
           studentData = data.getStudentData(studentID)
           update(label)
           return
        )
         */
        d3.select("#select-peer").on("change", function() {
          var peerData, peerType;
          peerType = this.value;
          peerData = data.getPeerData(peerType);
          update(label, true);
        });
        arcs.on("mouseover", function() {
          arcHover(this, 0.7, 0, 1);
        }).on("mouseout", function() {
          arcHover(this, 1, 1, 0);
        });
        arcs.attr("pointer-events", "none").transition().duration(durationNormal + durationShort * 1.5).transition().attr("pointer-events", "auto");
        arcs.on("click", function(d, i) {
          structure.checkThenRun(structure.getChildren(label)[i])(update);
        });
        backG.on("mouseover", function() {
          structure.checkThenRun(structure.getParent(label))(showHelpText);
        }).on("mouseout", hideHelpText);
        backG.on("click", function() {
          structure.checkThenRun(structure.getParent(label))(update);
        });
      };
      update = function(label, isFGNotAnimated) {
        render(null);
        render(label, isFGNotAnimated);
        if (label === "overall") {
          hideHelpText();
        }
      };
      hideHelpText = function() {
        return helpText.attr("opacity", 0);
      };
      showHelpText = function() {
        return helpText.attr("opacity", 0.2);
      };
      valToPercentString = function(val) {
        return (Math.abs(Math.floor(val * 100))) + "%";
      };
      generateComparisonText = function(val) {
        if (val >= 0) {
          return valToPercentString(val) + " ahead of peers";
        } else {
          return valToPercentString(val) + " behind peers";
        }
      };
      darkerRange = function(val) {
        if (val >= 0) {
          return val / 2 + 0.5;
        } else {
          return val / 2 - 0.5;
        }
      };
      isStudentID = function(str) {
        return !isNaN(str);
      };
      isPeerType = function(str) {
        return isNaN(str) && str.indexOf("get") < 0;
      };
      peerTypeToTitleText = {
        "avg": "all students",
        "top10_problem": "10 students completed most problems",
        "top10_video": "10 students completed most videos",
        "top10_active": "10 most active students",
        "top10_timespent": "10 students spent most time"
      };
      structure.getParent = function(label) {
        return this[category].parent[label];
      };
      structure.getChildren = function(label) {
        return this[category].children[label];
      };
      structure.checkThenRun = function(label) {
        if (label in this[category].children) {
          return function(nextstep) {
            return nextstep(label);
          };
        } else {
          return function(nextstep) {};
        }
      };
      data.getIDs = function(filter) {
        return Object.keys(this).filter(filter);
      };
      data.getPeerData = function(peerType) {
        return this[peerType][category];
      };
      data.getStudentData = function(id) {
        return this[id][category];
      };
      d3.select("#select-peer").selectAll("option").data(data.getIDs(isPeerType).sort()).enter().append("option").attr("value", function(d) {
        return d;
      }).text(function(d) {
        return peerTypeToTitleText[d];
      });
      category = d3.select("#select-category").property("value");
      peerType = d3.select("#select-peer").property("value");
      studentData = data.getStudentData(studentID);
      peerData = data.getPeerData(peerType);
      render("overall");
    });
  });
};
