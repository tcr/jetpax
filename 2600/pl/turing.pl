:- module(turing, [gem/1, turing/3, cpu_R/2, is_cpu/1]).
:- set_prolog_flag(verbose, silent). 
:- style_check(-singleton).

kernel(KA).
kernel(KB).

is_bool(true).
is_bool(false).

gem(g00).
gem(g01).
gem(g10).
gem(g11).

code(bc_VD1).
code(bc_VD0).
code(bc_STX).
code(bc_STY).
code(bc_NOP).

% for Kernel A
code(bc_RF1).
code(bc_RST).
code(bc_BLK). % only cancels third entry
% % code(bc_RF0).

% for Kernel B
% code(bc_P10).
% code(bc_P11).

should_occur_once(Prog, Bc) :- member(Bc, Prog).
should_follow(Prog, Bc) :- \+ (Prog = [Bc|_]).
should_be_pos(Prog, Poses) :- length(Prog, Len), \+ member(Len, Poses).

% search: ",bc_VD1" | "bc_RST"

% Constaints on opcodes.
opcode_violation(Prog, bc_VD0) :-
    should_occur_once(Prog, bc_VD0) ; % restrict count
    should_follow(Prog, bc_VD1). % only follow VD1 (Kernel A)
opcode_violation(Prog, bc_VD1) :-
    should_occur_once(Prog, bc_VD1) ; % restrict count
    should_be_pos(Prog, [0, 1, 2]). % restrict positions (Kernel A)
opcode_violation(Prog, bc_RST) :-
    should_occur_once(Prog, bc_RST) ; % only valid once
    should_be_pos(Prog, [1, 2, 3]). % only valid positions
opcode_violation(Prog, bc_BLK) :-
    should_occur_once(Prog, bc_BLK) ; % restrict count
    should_be_pos(Prog, [4]). % restrict positions
opcode_violation(Prog, bc_RF1) :-
    should_occur_once(Prog, bc_RF1) ; % restrict count
    should_be_pos(Prog, [2, 3, 4]). % restrict positions

opcode_violation(Prog, bc_P11) :-
    member(bc_P11, Prog) ; % only appear once
    member(bc_P10, Prog). % don't  mix.
opcode_violation(Prog, bc_P10) :-
    member(bc_P11, Prog) ; % only appear once
    member(bc_P10, Prog). % don't  mix.

reflect(false, g00, g00).
reflect(false, g01, g01).
reflect(false, g10, g10).
reflect(false, g11, g11).
reflect(true, g00, g00).
reflect(true, g01, g10).
reflect(true, g10, g01).
reflect(true, g11, g11).

% Compute GRP0
vm_grp0(bc_RST, Cpu, g00).
vm_grp0(Code, cpu(_, _, _, _, _, true, _), g00).
vm_grp0(Code, cpu(G, _, false, _, _, false, R), Out) :- reflect(R, G, Out).
vm_grp0(Code, cpu(_, V, true, _, _, false, R), Out) :- reflect(R, V, Out).

is_cpu(cpu(G, V, D, X, Y, B, R)) :-
    gem(G), gem(V), gem(X), gem(Y), is_bool(D), is_bool(B), is_bool(R).

% Extract Reflect value
cpu_R(cpu(_, _, _, _, _, _, R), R).

cpu_end_state(cpu(G, V, D, X, Y, B, false)).

% Bytecode
cpu_update(cpu(G, V, _, X, Y, B, R), bc_VD0, cpu(G, V, false, X, Y, B, R)).
cpu_update(cpu(G, V, _, X, Y, B, R), bc_VD1, cpu(G, V, true, X, Y, B, R)).
cpu_update(cpu(_, V, D, X, Y, B, R), bc_STX, cpu(X, V, D, X, Y, B, R)).
cpu_update(cpu(_, V, D, X, Y, B, R), bc_STY, cpu(Y, V, D, X, Y, B, R)).
cpu_update(cpu(_, V, D, X, Y, B, R), bc_P10, cpu(g10, V, D, X, Y, B, R)).
cpu_update(cpu(_, V, D, X, Y, B, R), bc_P11, cpu(g11, V, D, X, Y, B, R)).
cpu_update(cpu(G, V, D, X, Y, _, R), bc_BLK, cpu(G, V, D, X, Y, true, R)).
cpu_update(cpu(G, V, D, X, Y, B, _), bc_RF1, cpu(G, V, D, X, Y, B, true)).
cpu_update(cpu(G, V, D, X, Y, B, _), bc_RF0, cpu(G, V, D, X, Y, B, false)).
cpu_update(Cpu, bc_NOP, Cpu).
cpu_update(Cpu, bc_RST, Cpu).

% TODO: 6 is a freebie, as long as all relevant flags are off

%
% Turing Machine Framework
%

turing(state(Q0, Cpu), Tape0, Tape) :-
    perform(state(Q0, Cpu), [], Ls, Tape0, Rs),
    is_cpu(Cpu),
    cpu_end_state(Cpu),
    reverse([bc_NOP|Ls], Tape),
    maplist(code, Tape).

perform(state(qf, _), Ls, Ls, Rs, Rs) :- !.

% Q0 - the current state (or initial state before the "perform")
% Ls0 - the current set of symbols that are LEFT of the head
% Ls - the FINAL set of symbols that WILL BE left of the head after perform
% Rs0 - the current set of symbols that are RIGHT of the head
% Rs - the FINAL set of symbols that WILL BE right of the head after perform
perform(S0, Ls0, Ls, Rs0, Rs) :-
    % Read the symbol to the right of the head (Sym)
    symbol(Rs0, Sym, RsRest),

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
    \+ opcode_violation(Ls0, NewSym),

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
