:- begin_tests(turing).
:- use_module("turing.pl").

test(all_gems) :-
    forall((gem(A), gem(B), gem(C), gem(D), gem(E), gem(F)),
        turing(state(q0, _), [A, B, C, D, E, F], _)).

:- end_tests(turing).
