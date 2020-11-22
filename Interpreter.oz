\insert 'Unify.oz'

declare proc {Adjoin OldE X NewE}
    local Key in
        Key = {CreateVariable}
        {AdjoinAt OldE X Key NewE}
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
        [] [var ident(X) S]|T then
            local NewE in
                {Adjoin E X NewE}
                {ExecuteStack pairSE(s:[S] e:NewE)|pairSE(s:T e:E)|StackT}
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
{ExecuteStack [pairSE(s:Program e:'env')]}