:- begin_tests(turing).
:- use_module("turing.pl").

% solved:\s+(.*)\nSHARD\?\s+\1

% decoder

trim_lead([],[],_).
trim_lead([H|T],[H|T],J) :-
    dif(H,J).
trim_lead([J|T],T2,J) :-
    trim_lead(T,T2,J).

lead(T, T2) :-
    [J|_] = T,
    trim_lead(T, T1, J),
    append(T2, T1, T).

% https://stackoverflow.com/questions/27479915/how-to-trim-first-n-elements-from-in-list-in-prolog
leading(L,S) :-      % to trim leading elements from a list
    nth0(0, L, Lead),
    strip_while(L, Lead, S).

shard_relation(Gems, Shard, Index, Item) :-
    nth0(0, Shard, VD0Index),
    nth0(1, Shard, RSTIndex),
    nth0(2, Shard, RF1Index),
    nth0(3, Shard, VDXIndex),
    (
        VD0Index > 0, VD0Index is Index + 1 -> Item = bc_VD1 ;
        VD0Index > 0, VD0Index == Index -> Item = bc_VD0 ;
        RSTIndex > 0, RSTIndex == Index -> Item = bc_RST ;
        RF1Index > 0, RF1Index == Index -> Item = bc_RF1 ;

        VDXIndex > 0, VDXIndex is Index - 1 -> Item = bc_VDX ;

        % Find STY
        Index > 0,
        max_list([VD0Index, RSTIndex, RF1Index], Max0),
        Max is Max0 + 2,
        sublist_to(Gems, Max, 5, Sublist),
        % print("sublist:"), print(Sublist), nl,
        lead(Sublist, Output),
        % print("output:"), print(Output), nl,
        length(Output, StyIndex),
        !,
        % print("idx:"), print(Max + StyIndex), nl,
        StyIndex > 0, StyIndex \= 3,
        YIndex is Max + StyIndex - 1,
        nth0(YIndex, Gems, YVal),
        nth0(Index, Gems, IndexVal),
        % print(YVal), nl,
        % print(IndexVal), nl,
        YVal == IndexVal -> Item = bc_STY ;

        Index > 0 -> Item = bc_STX ;

        Item = bc_NOP
    ).

test(all_gems) :-
    forall((gem(A), gem(B), gem(C), gem(D), gem(E), gem(F)),
        (Gems = [A, B, C, D, E, F],
        nl,
        write_term("gems:     ", []), print(Gems), nl,
        turing(state(q0, Cpu), Gems, Program),
        write_term("cpu:      ", []), print(Cpu), nl,
        append(Prg, [_], Program),
        write_term("solved:   ", []), print(Prg), nl,

        condense_program(Program, Shard),   
        !,     
        (
            % Skip BLK segments for now
            length(Program, ProgramLen), (ProgramLen < 6) ;

            % print(Shard), nl, nl,
            Res = [A0, B0, C0, D0, E0, bc_NOP],
            shard_relation(Gems, Shard, 0, A0),
            shard_relation(Gems, Shard, 1, B0),
            shard_relation(Gems, Shard, 2, C0),
            shard_relation(Gems, Shard, 3, D0),
            shard_relation(Gems, Shard, 4, E0),
            
            % print(Res), nl,
            % print(Program), nl,
            append(Gems2, [_], Gems),
            append(Res2, [_], Res),
            % print(Gems2), nl,
            write_term("SHARD?    ", []), print(Res2), nl,
            write_term("shard:    ", []), print(Shard), nl
            % TODO test these values
            % turing_impl(state(q0, Cpu), Gems2, Res2)

            % append(Program2, [_], Program)
            % Res2 == Program2
        ))).

    % print("hello that's the end of that"), nl,

    % code(A), code(B), code(C), code(D), code(E), code(F),
    % turing(state(q0, cpu(g01,g00,true,g11,g10,_,false)), [_,_,_,_,g01,_], [A, B, C, D, E, F]),
    % condense_program([A, B, C, D, E, F], [1,0,4,0]),
    % print([A, B, C, D, E, F]), nl,
    % % Kernel B: cpu_R(Cpu, false),
    % write_term("single state: ", []), print(cpu(g01,g00,true,g11,g10,_,false)), nl, nl,
    % write_term("single bytecode: ", []), print(Gems), nl, nl.

:- end_tests(turing).
