:- module(turing, [gem/1, turing/3, cpu_R/2, is_cpu/1, kernel/1, condense_program/2, code/1, sublist_to/4, turing_check/3]).
:- set_prolog_flag(verbose, silent). 
:- style_check(-singleton).

:- nb_setval(enable_reflect, false).

kernel(ka).
% kernel(kb).

is_bool(true).
is_bool(false).

gem(g00).
gem(g01).
gem(g10).
gem(g11).

% all kernels
code(bc_VD1).
code(bc_VD0).
code(bc_STX).
code(bc_STY).
code(bc_NOP).

% for Kernel A
code(bc_RST) :- kernel(ka).
code(bc_RF1) :- kernel(ka), nb_getval(enable_reflect, Out), Out.
% code(bc_VDX) :- kernel(ka). % Duplicate VD1 reserved for position 4
% % code(bc_RF0).

% for Kernel B
code(bc_P10) :- kernel(kb).
code(bc_P11) :- kernel(kb).

% search: ",bc_VD1" | "bc_RST"

% Constaints on opcodes.
should_occur_once(Prog, Bc) :- member(Bc, Prog).
should_follow(Prog, Bc) :- \+ (Prog = [Bc|_]).
should_be_pos(Prog, Poses) :- length(Prog, Len), \+ member(Len, Poses).

/*

hash(Prog) :-
    % VD0(2): 1, 2, 3, -
    % RST(2): 1, 2, 3, -
    % RF1(2): 2, 3, 4
    % VPX + RF1(1) (howwww)

    From this + TIA rules we can compute what vlaues need to go where
    bashed off the hash itself!

    VD0 == 1 ? VDEL = G0, GRP0 = G1, [VD1,VD0...]
    VD0 == 2 ? VDEL = G1, GRP0 = G0  [...,VD1,VD0...]
    VD0 == 3 ? VDEL = G2, GRP0 = G0  [...,...,VD1,VD0...]

    SET RST = value
    SET RF1 = value
    SET VPX + RF1 = value

    First value, if blank, should be NOP

    Scan left (from second on) to right:
    [STX when available, and set X from it]
    [STY when next changes, and set Y from it]
    VDELon is ???
    reflect is ???

*/

condense_program(Prog, Out) :-
    (nth0(VD0Index, Prog, bc_VD0); VD0Index = 0),
    (nth0(RSTIndex, Prog, bc_RST); RSTIndex = 0),
    (nth0(RF1Index, Prog, bc_RF1); RF1Index = 0),
    Out = [VD0Index,RSTIndex,RF1Index].

opcode_violation(Prog, cpu(G, V, _, _, _, _), bc_VD0) :-
    should_occur_once(Prog, bc_VD0) ; % restrict count
    should_follow(Prog, bc_VD1) ; % only follow VD1 (Kernel A)
    (\+ (G == g11 ; G == g01) ; \+ (V == g11 ; V == g01)).
opcode_violation(Prog, cpu(_, _, D, _, _, _), bc_VD1) :-
    should_occur_once(Prog, bc_VD1) ; % restrict count
    length(Prog, Len), Len == 1, D == true ;
    % length(Prog, Len), Len == 2, D == true ;
    should_be_pos(Prog, [1, 4]). % restrict positions (Kernel A)
opcode_violation(Prog, _, bc_RST) :-
    % nth0(Index, Prog, bc_RST), Index \= 1 ; % TODO only valid once
    should_be_pos(Prog, [0, 1, 2, 3]). % only valid positions
opcode_violation(Prog, _, bc_RF1) :-
    should_occur_once(Prog, bc_RF1) ; % restrict count
    should_be_pos(Prog, [1, 2, 3]). % restrict positions
% opcode_violation(Prog, cpu(_, V, _, _, _, _, _), bc_VDX) :-
%     % V \= g00 ;
%     should_be_pos(Prog, [4]). % restrict positions

opcode_violation(Prog, _, bc_P11) :-
    member(bc_P11, Prog) ; % only appear once
    member(bc_P10, Prog) ; % don't  mix.
    should_be_pos(Prog, [2, 3, 4]). % restrict positions
opcode_violation(Prog, _, bc_P10) :-
    member(bc_P11, Prog) ; % only appear once
    member(bc_P10, Prog) ; % don't  mix.
    should_be_pos(Prog, [2, 3, 4]). % restrict positions

% Reflection map
reflect(false, g00, g00). reflect(false, g01, g01). reflect(false, g10, g10). reflect(false, g11, g11).
reflect(true, g00, g00). reflect(true, g01, g10). reflect(true, g10, g01). reflect(true, g11, g11).

% Compute GRP0
vm_grp0(bc_RST, Cpu, g00).
vm_grp0(Code, cpu(G, _, false, _, _, R), Out) :- reflect(R, G, Out).
vm_grp0(Code, cpu(_, V, true, _, _, R), Out) :- reflect(R, V, Out).

is_cpu(cpu(G, V, D, X, Y, R)) :-
    gem(G), gem(V), gem(X), gem(Y), is_bool(D), is_bool(R).

% Extract Reflect value
cpu_R(cpu(_, _, _, _, R), R).

cpu_end_state(cpu(G, V, D, X, Y, R)).

% Bytecode
cpu_update(cpu(_, V, D, X, Y, R), bc_STX, cpu(X, V, D, X, Y, R)).
cpu_update(cpu(_, V, D, X, Y, R), bc_STY, cpu(Y, V, D, X, Y, R)).
cpu_update(cpu(_, V, D, X, Y, R), bc_P10, cpu(g10, V, D, X, Y, R)).
cpu_update(cpu(_, V, D, X, Y, R), bc_P11, cpu(g11, V, D, X, Y, R)).
cpu_update(cpu(G, V, _, X, Y, R), bc_VD0, cpu(G, V, false, X, Y, R)).
cpu_update(cpu(G, V, _, X, Y, R), bc_VD1, cpu(G, V, true, X, Y, R)).
cpu_update(cpu(G, V, _, X, Y, R), bc_VDX, cpu(G, V, true, X, Y, R)).
cpu_update(cpu(G, V, D, X, Y, _), bc_RF0, cpu(G, V, D, X, Y, false)).
cpu_update(cpu(G, V, D, X, Y, _), bc_RF1, cpu(G, V, D, X, Y, true)).
cpu_update(Cpu, bc_NOP, Cpu).
cpu_update(Cpu, bc_RST, Cpu).

% TODO: 6 is a freebie, as long as all relevant flags are off

%
% Turing Machine Framework
%

% https://stackoverflow.com/questions/20765479/create-a-sublist-from-a-list-given-an-index-and-a-number-of-elements-prolog
sublist(List, From, Count, SubList) :-
    To is From + Count - 1,
    findall(E, (between(From, To, I), nth1(I, List, E)), SubList).

sublist_to(List, From, To, SubList) :-
    findall(E, (between(From, To, I), nth1(I, List, E)), SubList).

turing(state(Q0, Cpu), Tape0, Tape) :-
    % HACK: Trim first two or last two from selection
    (append(_, [g00, g00], Tape0) -> sublist(Tape0, 1, 4, Tape1); Tape1 = Tape0),
    (append([g00, g00], _, Tape1) -> sublist(Tape1, 3, 4, Tape2); Tape2 = Tape1),

    % HACK: Don't reflect so often.
    (nb_setval(enable_reflect, false),
        perform(state(Q0, Cpu), [], Ls, Tape2, Rs) ;
    nb_setval(enable_reflect, true),
        perform(state(Q0, Cpu), [], Ls, Tape2, Rs)),

    is_cpu(Cpu),
    cpu_end_state(Cpu),
    reverse([bc_NOP|Ls], Tape),
    maplist(code, Tape).

turing_check(_, [], []) :- !.
turing_check(S0, [Gem|Gems], [Code|Prog]) :-
    rule(S0, Gem, S, Code, right),
    turing_check(S, Gems, Prog).

perform(state(qf, _), Ls, Ls, Rs, Rs) :- !.
    
% Q0 - the current state (or initial state before the "perform")
% Ls0 - the current set of symbols that are LEFT of the head
% Ls - the FINAL set of symbols that WILL BE left of the head after perform
% Rs0 - the current set of symbols that are RIGHT of the head
% Rs - the FINAL set of symbols that WILL BE right of the head after perform
perform(S0, Ls0, Ls, Rs0, Rs) :-
    % Read the symbol to the right of the head (Sym)
    symbol(Rs0, Sym, RsRest),

    % print(Ls0), nl,

    % Apply first found matching rule to the current state (Q0)
    % and the current symbol on the right (Sym), resulting in
    % a new symbol (NewSym) and an action (Action)
    rule(S0, Sym, S1, NewSym, Action),

    % Perform the action using the current list of symbols on the left (Ls0)
    % and the updates list of symbols on the right (old right symbol (Sym)
    % replaced by the new right symbol (NewSym), which is [NewSym|RsRest]
    % with the action resulting in new left Ls1 and new right Ls2
    % sets of symbols
    action(Action, Ls0, Ls1, [NewSym|RsRest], Rs1),
    S0 = state(_, Cpu0),
    \+ opcode_violation(Ls0, Cpu0, NewSym),

    % Recursively perform the Turing engine on the new state, left,
    % and right sets of symbols until we hit the final state (qf)
    % with final result being left symbols, Ls, and right symbols, Rs
    perform(S1, Ls1, Ls, Rs1, Rs).

% symbol([], b, []).
symbol([Sym], b, [Sym]). % HACK: 6 is a freebie
symbol([Sym|Rs], Sym, Rs).

action(left, Ls0, Ls, Rs0, Rs) :- left(Ls0, Ls, Rs0, Rs).
action(stay, Ls, Ls, Rs, Rs).
action(right, Ls0, [Sym|Ls0], [Sym|Rs], Rs).

left([], [], Rs0, [b|Rs0]).
left([L|Ls], Ls, Rs, [L|Rs]).

% Output image must match input
rule(state(q0, Cpu), Gem, state(q0, NewCpu), Code, right) :-
    gem(Gem), code(Code),
    cpu_update(Cpu, Code, NewCpu),
    vm_grp0(Code, NewCpu, Gem).

rule(state(q0, Cpu), b, state(qf, Cpu), eof, stay).
