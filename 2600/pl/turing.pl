:- module(turing, [gem/1, turing/3]).

:- set_prolog_flag(verbose, silent). 

gem(g00).
gem(g01).
gem(g10).
gem(g11).

code(bc_nop).
code(bc_vdel_on).
code(bc_vdel_off).
code(bc_stx).
code(bc_sty).


% BlankOn,
% Stx,
% Sty,
% Php10,
% Php11,
% Reflect,
% Reset4,

% Grp0, Vdel, VdelOn, X, Y
vm_grp0(cpu(G, _, false, _, _), G).
vm_grp0(cpu(_, V, true, _, _), V).

cpu_update(Cpu, bc_nop, Cpu).
cpu_update(cpu(G, V, _, X, Y), bc_vdel_off, cpu(G, V, false, X, Y)).
cpu_update(cpu(G, V, _, X, Y), bc_vdel_on, cpu(G, V, true, X, Y)).
cpu_update(cpu(_, V, D, X, Y), bc_stx, cpu(X, V, D, X, Y)).
cpu_update(cpu(_, V, D, X, Y), bc_sty, cpu(X, V, D, X, Y)).

% state(Q, Cpu).

turing(S0, Tape0, Tape) :-
    print(Tape0), nl,
    perform(S0, [], Ls, Tape0, Rs),
    reverse(Ls, Ls1),
    append(Ls1, Rs, Tape).

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

    % Recursively perform the Turing engine on the new state, left,
    % and right sets of symbols until we hit the final state (qf)
    % with final result being left symbols, Ls, and right symbols, Rs
    perform(S1, Ls1, Ls, Rs1, Rs).

symbol([], b, []).
symbol([Sym|Rs], Sym, Rs).

action(left, Ls0, Ls, Rs0, Rs) :- left(Ls0, Ls, Rs0, Rs).
action(stay, Ls, Ls, Rs, Rs).
action(right, Ls0, [Sym|Ls0], [Sym|Rs], Rs).

left([], [], Rs0, [b|Rs0]).
left([L|Ls], Ls, Rs, [L|Rs]).

% Output image must match input
rule(state(q0, Cpu), Gem, state(q0, NewCpu), Code, right) :-
    gem(Gem), code(Code), cpu_update(Cpu, Code, NewCpu), vm_grp0(NewCpu, Gem).

rule(state(q0, Cpu), b, state(qf, Cpu), eof, stay).
