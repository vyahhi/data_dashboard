student_box = (student_ids, curr_student_id) ->

    # init selectbox for student ID
    d3.select("#select-student")
       .selectAll("option")
       .data(student_ids)
       .enter()
       .append("option")
       .attr("value", (student) -> student.user_id)
       .attr("selected", (student) -> if student.user_id == curr_student_id then "selected" else null)
       .text((student) -> "Student " + student.user_id)
       .on("click", (student) ->
          if student.user_id != curr_student_id
             window.location.pathname = "/student/#{ student.user_id }?course=67"
          return
       )


    d3.select("#select-student")
       .on("click", (student, i) ->)
    return