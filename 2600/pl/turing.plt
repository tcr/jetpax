:- begin_tests(turing).
:- use_module("turing.pl").

test(all_gems) :-
    % forall((gem(A), gem(B), gem(C), gem(D), gem(E), gem(F)),
    %     (Tape = [A, B, C, D, E, F],
    %     write_term("gems: ", []), print(Tape), nl,
    %     turing(state(q0, Cpu), Tape, Program),
    %     condense_program(Program, Shard),
    %     print(Shard), nl,
    %     % Kernel B: cpu_R(Cpu, false),
    %     write_term("state: ", []), print(Cpu), nl, nl,
    %     write_term("bytecode: ", []), print(Program), nl, nl)),

    print("hello that's the end of that"), nl,

    code(A), code(B), code(C), code(D), code(E), code(F),
    turing(state(q0, cpu(g01,g00,true,g11,g10,_,false)), [_,_,_,_,g01,_], [A, B, C, D, E, F]),
    condense_program([A, B, C, D, E, F], [1,0,4,0]),
    print([A, B, C, D, E, F]), nl,
    % Kernel B: cpu_R(Cpu, false),
    write_term("single state: ", []), print(cpu(g01,g00,true,g11,g10,_,false)), nl, nl,
    write_term("single bytecode: ", []), print(Gems), nl, nl.

:- end_tests(turing).
