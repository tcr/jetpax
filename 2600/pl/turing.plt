:- begin_tests(turing).
:- use_module("turing.pl").

test(all_gems) :-
    forall((gem(A), gem(B), gem(C), gem(D), gem(E), gem(F)),
        (Tape = [A, B, C, D, E, F],
        write_term("gems: ", []), print(Tape), nl,
        turing(state(q0, Cpu), Tape, Program),
        % Kernel B: cpu_R(Cpu, false),
        write_term("state: ", []), print(Cpu), nl, nl,
        write_term("bytecode: ", []), print(Program), nl, nl)).

:- end_tests(turing).
