:- begin_tests(turing).
:- use_module("turing.pl").

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

shard_relation(Gems, Shard, Index, Item) :-
    nth0(0, Shard, VD0Index),
    nth0(1, Shard, RSTIndex),
    nth0(2, Shard, RF1Index),
    % nth0(3, Shard, VDXIndex),
    (
        VD0Index > 0, VD0Index is Index + 1 -> Item = bc_VD1 ;
        VD0Index > 0, VD0Index == Index -> Item = bc_VD0 ;
        RSTIndex > 0, RSTIndex == Index -> Item = bc_RST ;
        RF1Index > 0, RF1Index == Index -> Item = bc_RF1 ;

        % VDXIndex > 0, VDXIndex is Index -> Item = bc_VDX ;

        % Compile a populated list of indices, "StateList"
        VD1Index is VD0Index - 1,
        StateList0 = [VD1Index, VD0Index, RF1Index, RSTIndex],

        % TODO move this into the join with [1,2,3,4] in subtract, or better yet filter on the indexes
        % like assembly will do
        % Add index 1 if it's equal to index 0
        (
            nth0(0, Gems, Val1), nth0(1, Gems, Val2), Val1 == Val2 -> append(StateList0, [1], StateList1) ;
            StateList1 = StateList0
        ),
        % Add index 2 if it's equal to index 1
        (
            nth0(1, Gems, Val1), nth0(2, Gems, Val2), Val1 == Val2 -> append(StateList1, [2], StateList) ;
            StateList = StateList1
        ),

        list_to_set(StateList, UsedIndices0),
        select(0, UsedIndices0, UsedIndices), % normalize indices by removing 0 (null)
        subtract([1,2,3,4], UsedIndices, FreeIndices), % get which indices aren't occupied
        maplist([In,Out]>>nth0(In, Gems, Out), FreeIndices, FreeValues),
        list_to_set(FreeValues, FreeSet),
        print(FreeValues), nl,
        nth0(0, FreeSet, XVal),
        (nth0(1, FreeSet, YVal) ; YVal = XVal),
        (nth0(2, FreeSet, ZVal) ; ZVal = XVal),

        nth0(Index, Gems, IndexVal),
        (
            % IndexVal == g00, \+ member(g00, [XVal, YVal, ZVal]) -> Item = bc_RST ;
            member(Index, FreeIndices), XVal == IndexVal -> Item = bc_STX ;
            member(Index, FreeIndices), YVal == IndexVal -> Item = bc_STY ;
            Index == 4, member(Index, FreeIndices), ZVal == IndexVal -> Item = bc_VDX ;
            Item = bc_NOP
        )
    ).

test(all_gems) :-
    forall((gem(A), gem(B), gem(C), gem(D), gem(E), gem(F)),
        (Gems = [A, B, C, D, E, F],
        nl,
        write_term("gems:     ", []), print(Gems), nl,
        turing(state(q0, Cpu), Gems, Program),
        write_term("cpu:      ", []), print(Cpu), nl,
        append(Prg, [_], Program),
        write_term("solved:   ", []), print(Prg), nl
        )).

        % condense_program(Program, Shard),   
        % !,
        % (
        %     % Skip BLK segments for now
        %     length(Program, ProgramLen), (ProgramLen < 6) ;

        %     % print(Shard), nl, nl,
        %     Res = [A0, B0, C0, D0, E0, bc_NOP],
        %     shard_relation(Gems, Shard, 0, A0),
        %     shard_relation(Gems, Shard, 1, B0),
        %     shard_relation(Gems, Shard, 2, C0),
        %     shard_relation(Gems, Shard, 3, D0),
        %     shard_relation(Gems, Shard, 4, E0),
            
        %     % print(Res), nl,
        %     % print(Program), nl,
        %     append(Res2, [_], Res),
        %     write_term("SHARD?    ", []), print(Res2), nl,
        %     write_term("shard:    ", []), print(Shard), nl,
        %     print(Cpu), nl,
        %     % NOTE: Cpu here is optional
        %     turing_check(state(q0, _), Gems2, Res2),
        %     append(Gems2, [_], Gems)

        %     % append(Program2, [_], Program)
        %     % Res2 == Program2
        % ))).

    % print("hello that's the end of that"), nl,

    % code(A), code(B), code(C), code(D), code(E), code(F),
    % turing(state(q0, cpu(g01,g00,true,g11,g10,_,false)), [_,_,_,_,g01,_], [A, B, C, D, E, F]),
    % condense_program([A, B, C, D, E, F], [1,0,4,0]),
    % print([A, B, C, D, E, F]), nl,
    % % Kernel B: cpu_R(Cpu, false),
    % write_term("single state: ", []), print(cpu(g01,g00,true,g11,g10,_,false)), nl, nl,
    % write_term("single bytecode: ", []), print(Gems), nl, nl.

:- end_tests(turing).
