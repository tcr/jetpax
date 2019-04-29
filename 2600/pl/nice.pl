% disjunctive facts
% https://stackoverflow.com/questions/32452350/prolog-simulate-disjunctive-facts?rq=1
% books
% http://www.learnprolognow.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse22
% http://www.swi-prolog.org/pldoc/man?section=clpfd
% https://www.metalevel.at/prolog/introduction
% constraints
% http://swi-prolog.996271.n3.nabble.com/Finite-State-Automata-in-Prolog-tp1819p1822.html

:- [library(chr)].

:- chr_constraint q1/0, q2/0, q3/0, q4/0, done/0, input/1.
q1, input(1) <=> q1.
q1, input(2) <=> q1.
q1, input(3) <=> q1.
q1, input(4) <=> q1.
q1, input(5) <=> q2.

card(1). card(2). card(3). card(4). card(5).

owns(bob, oneof, [1,2]).  % i.e., at least one of

owns(bob, not, 2).

owns(bob, not, 3).

hand(bob, Hand) :-
   % bob has two distinct cards:
   card(X),
   card(Y),
   X < Y,
   Hand = [X, Y],
   (q1, input(Y)) == q2,
   % if there is a "oneof" constraint, check it:
   (owns(bob, oneof, S) -> (member(A,S), member(A, Hand)) ; true),
   % check all the "not" constraints:
   ((owns(bob, not, Card), member(Card,Hand)) -> false; true).


% hand(bob, Hand).
