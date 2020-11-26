\insert 'Unify.oz'

declare fun {ComputeClosure S E}
% TODO: add [match ...] 
    case S of nil then env() 
    [] [nop] then
        env()
    [] [var ident(X) S1] then
        {Record.subtract {ComputeClosure S1 {Adjoin env(X:unbound) E}} X}
    [] [bind ident(X) ident(Y)] then 
        env(X:E.X Y:E.Y)
    [] [bind ident(X) literal(_)] then 
        env(X:E.X)
    [] [bind ident(X) [record literal(_) Pairs]] then
        local VarList VarListMapped in
            VarList = {Map Pairs fun {$ A} case A.2.1 of ident(A1) then A1 else nil end end}
            VarListMapped = {Map VarList fun {$ A} A#E.A end}
            {AdjoinList env(X:E.X) VarListMapped}
        end
    [] [bind ident(X) [procedure ArgList S1]] then
        local VarList VarListMapped in
            VarList = {Map ArgList fun {$ A} case A of ident(A1) then A1 else nil end end}
            VarListMapped = {Map VarList fun {$ A} A#unbound end}
            {Adjoin {Record.subtractList {ComputeClosure S1 {AdjoinList E VarListMapped}} VarList} env(X:E.X)}
        end
    [] H|T then
        {Adjoin {ComputeClosure H E} {ComputeClosure T E}}
    end
end

% Adds new bindings for pattern matching in E and binds the result to NewE.
declare proc {PatternMatchCreateE XFields PFields E NewE}
    case PFields of nil then NewE = E
    [] [literal(_) ident(HP)]|TP then
        case XFields of [literal(_) HX]|TX then
            local TempE in
                {AdjoinAt E HP {CreateVariable} TempE}
                {Unify ident(HP) HX TempE}
                {PatternMatchCreateE TX TP TempE NewE}
            end
        end
    end
end

% Checks if records XVal and P match. if yes then adds new bindings to E and binds to NewE. RecordsMatch binds to return boolean value
declare proc {CheckMatchAndGiveE XVal P E RecordsMatch NewE}
    % Check same record name:
    if XVal.2.1 \= P.2.1 then RecordsMatch=false
    % Check they have same number of features:
    elseif {Length XVal.2.2.1} \= {Length P.2.2.1} then RecordsMatch=false
    else
        % Sort the features using Canonize (given by sir) and check if features are same.
        local XFields PFields in
            XFields = {Canonize XVal.2.2.1}
            PFields = {Canonize P.2.2.1}
            if {Map XFields fun {$ X} X.1 end} \= {Map PFields fun {$ X} X.1 end} then RecordsMatch=false
            else
                RecordsMatch=true
                {PatternMatchCreateE XFields PFields E NewE}
            end
        end
    end    
end

% This function ExecuteStacks a given stack
declare proc {ExecuteStack Stack}
    case Stack of nil then skip
    [] pairSE(s:S e:E)|StackT then
        {Browse 'Stack:'#Stack}
        {Browse 'SAS:'#{Dictionary.entries SAStore}}
        {Browse 'E:'#E}
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
        [] [bind ident(X) [procedure ArgList S1]]|T then
            local VarList VarListMapped Closure in
                VarList = {Map ArgList fun {$ A} case A of ident(A1) then A1 else nil end end}
                VarListMapped = {Map VarList fun {$ A} A#unbound end}
                Closure = {ComputeClosure S1 {AdjoinList E VarListMapped}}
                {Unify ident(X) procedure(ArgList S1 Closure) E}
                {ExecuteStack pairSE(s:T e:E)|StackT}
            end
        [] [match ident(X) P S1 S2]|T then
            local XVal in
                XVal = {RetrieveFromSAS E.X}
                case XVal of record|literal(_)|_|nil then
                    % P is a record. Check if records match:
                    local RecordsMatch NewE in
                        {CheckMatchAndGiveE XVal P E RecordsMatch NewE}
                        if RecordsMatch then
                            {ExecuteStack pairSE(s:[S1] e:NewE)|pairSE(s:T e:E)|StackT}
                        else
                            {ExecuteStack pairSE(s:[S2] e:E)|pairSE(s:T e:E)|StackT}
                        end
                    end
                [] equivalence(_) then {Raise unboundInPatternMatch(X P)}
                else % X is not a record.
                    {ExecuteStack pairSE(s:[S2] e:E)|pairSE(s:T e:E)|StackT}
                end            
            end
        [] SList|T then % Handle nested statement
            {ExecuteStack pairSE(s:SList e:E)|pairSE(s:T e:E)|StackT}
        end
    end
end

% Program = [[var ident(foo)
%   [var ident(bar)
%    [var ident(baz)
%     [[bind ident(foo) ident(bar)]
%      [bind ident(bar) literal(20)]
%      [match ident(foo) literal(21)
%       [bind ident(baz) literal(t)]
%       [bind ident(baz) literal(f)]]
%      %% Check
%      [bind ident(baz) literal(f)]
%      [nop]]]]]]
Program = [[var ident(foo)
                [var ident(bar)
                    [var ident(quux)
                        [[bind ident(bar) 
                            [procedure [ident(baz)] [bind ident(baz) [record literal(person) [[literal(age) ident(foo)]] ] ] ]
                        ]
            % [apply ident(bar) ident(quux)]
                        [bind ident(quux) [record literal(person) [[literal(age) literal(40)]]]]
                        [bind ident(foo) literal(42)]]
                    ]
                ]
            ]
          ]

{ExecuteStack [pairSE(s:Program e:env())]}
{Browse 'COMPLETED'}