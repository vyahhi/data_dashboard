student_box = (student_ids, curr_student_id) ->

    # init selectbox for student ID
    d3.select("#select-student")
       .selectAll("option")
       .data(student_ids)
       .enter()
       .append("option")
       .attr("value", (student) -> student.id)
       .attr("selected", (student) -> if student.id == curr_student_id then "selected" else null)
       .text((student) -> "Student " + student.id)
       .on("click", (student) ->
          if student.id != curr_student_id
             window.location.pathname = "/student/#{ student.id }"
          return
       )


    d3.select("#select-student")
       .on("click", (student, i) ->)
    return