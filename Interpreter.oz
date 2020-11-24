\insert 'Unify.oz'

declare fun {ComputeClosure S E}
    case S of H|T then 
        {Adjoin {ComputeClosure H E} {ComputeClosure T E}}
    [] [var ident(X) S1] then 
        {Record.subtract {ComputeClosure S1 {Adjoin env(X:unbound) E}} X}
    [] [bind ident(X) ident(Y)] then 
        env(X:E.X Y:E.Y)
    [] [bind ident(X) literal(V)] then 
        env(X:E.X)
    [] [bind ident(X) [record literal(A) Pairs]] then
        local VarList VarListMapped in
            VarList = {Map Pairs fun {$ A} case A.2.1 of ident(A1) then A1 else nil end end}
            VarListMapped = {Map VarList fun {$ A} A#E.A end}
            {AdjoinList env(X:E.X) VarListMapped}
        end
    [] [bind ident(X) [procedure ArgList S1]] then
        local VarList VarListMapped in
            VarList = {Map ArgList fun {$ A} case A.1 of ident(A1) then A1 else nil end end}
            VarListMapped = {Map VarList fun {$ A} A#unbound end}
            {Adjoin {Record.subtractList {ComputeClosure S1 {AdjoinList E VarListMapped}} VarList} env(X:E.X)}
        end
    end
end

% This function ExecuteStacks a given stack
declare proc {ExecuteStack Stack}
    {Browse Stack}
    {Browse {Dictionary.entries SAStore}}
    case Stack of nil then skip
    [] pairSE(s:S e:E)|StackT then
        case S of nil then {ExecuteStack StackT}
        [] [nop]|T then
            {ExecuteStack pairSE(s:T e:E)|T}
        [] [var ident(X) S1]|T then
            local NewE in
                {AdjoinAt E X {CreateVariable} NewE}
                {ExecuteStack pairSE(s:[S1] e:NewE)|pairSE(s:T e:E)|StackT}
            end
        [] [bind ident(X) ident(Y)]|T then
            {Unify ident(X) ident(Y) E}
            {ExecuteStack pairSE(s:T e:E)|StackT}
        [] [bind ident(X) literal(V)]|T then
            {Unify ident(X) literal(V) E}
            {ExecuteStack pairSE(s:T e:E)|StackT}
        [] [bind ident(X) [record literal(A) Pairs]]|T then
            {Unify ident(X) [record literal(A) Pairs] E}
            {ExecuteStack pairSE(s:T e:E)|StackT}
        [] [bind ident(X) [procedure ArgList S1]] then
            local VarList VarListMapped Closure in
                VarList = {Map ArgList fun {$ A} case A.1 of ident(A1) then A1 else nil end end}
                VarListMapped = {Map VarList fun {$ A} A#unbound end}
                Closure = {ComputeClosure S1 {AdjoinList E VarListMapped}}
                {Unify ident(X) procedure(ArgList S1 Closure) E}
            end
        [] SList|T then % Handle nested statement
            {ExecuteStack pairSE(s:SList e:E)|pairSE(s:T e:E)|StackT}
        end
    end
end

Program = [[var ident(x) 
            [[var ident(y) 
                [[bind ident(x) ident(y)]
                [bind ident(y) [record literal('bruh') [[literal(firstname) literal('hello')]]]]
            ]]
            [var ident(z) [
                [bind ident(x) [record literal('bruh') [[literal(firstname) ident(z)]]]]
            ]]
            ]
        ]]
{ExecuteStack [pairSE(s:Program e:env())]}