# Oz-Interpreter

This Interpreter is built for Oz language for an Oz AST. This assignment is a part of the course CS350 offered at IIT Kanpur by Prof Satyadev Nandakumar in Fall 2020. The basic functionalities implemented are as follows,

- Question 1
Implement a stack that can simulate [[nop] [nop] [nop] [nop]]

- Question 2
Implement Variable Creation using Unify.oz [var ident(x) s]

- Question 3
Implement Variable-to-Variable binding i.e [bind ident(x) ident(y)]

- Question 4
Implement Value Creation
(a) [bind ident(x) literal(n)] (b) records (c) procedures

- Question 5
Implement [match ident(x) p s1 s2] where p is a record

- Question 6
Implement [apply ident(f) ident(x1) ... ident(xn)] that applies a procedure stored in variable f.


Team Members
- Abhyuday Pandey (170039)
- Srinjay Kumar   (170722)
- Umang Malik     (170765)

Instructions
- Extract all the files in the same folder.
- To run any test case
- Open tests.oz
- Uncomment any part to run
- Run the testcase as {ExecuteStack [pairSE(s:Testcase e:env())]} 
