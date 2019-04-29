gem(g00). gem(g01). gem(g10). gem(g11).

state(Init, Bytecode) :-
    gem(Init),
    is_list(Bytecode).

gems([A, B], state(Init, Bytecode)) :-
    gem(A),
    gem(B),
    Init = A.

/*

?- Input = ["11", "01"], state(Input);
_2816
gems([g11, g01]).

*/
