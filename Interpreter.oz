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
    case Stack of nil then skip
    [] pairSE(s:S e:E)|StackT then
        case S of nil then {ExecuteStack StackT}
        [] [nop]|T then
            {Browse 'Inside nop'}
            {ExecuteStack pairSE(s:T e:E)|T}
        [] [var ident(X) S]|T then
            {Browse 'Inside ident(X)'}
            local NewE in
                {Adjoin E X NewE}
                % TODO: Use Adjunction to get new environment from E.
                % NewE = .....
                {ExecuteStack pairSE(s:[S] e:NewE)|pairSE(s:T e:E)|StackT}
            end
        [] [bind ident(X) ident(Y)]|T then
            {Browse 'Inside bind ident(x) ident(y)'}
            {Unify ident(X) ident(Y) E}
            {ExecuteStack pairSE(s:T e:E)|StackT}
        [] SList|T then % Handle nested statement
            {ExecuteStack pairSE(s:SList e:E)|pairSE(s:T e:E)|StackT}
        end
    end
end

Program = [[var ident(x) [var ident(y) [nop]]]]
{ExecuteStack [pairSE(s:Program e:nil)]}