\insert 'Interpreter.oz'

% %%%%%%%%%%% Testing the stack (Question 1)
% Q1 = [[nop] [nop] [nop] [nop]]

% {ExecuteStack [pairSE(s:Q1 e:env())]}
% {Browse 'COMPLETED'}


%%%%%%%%%%% Testing variable declaration (Question 2)
% local Foo in
%     local Bar in
%         local Goz in
%             skip
%         end
%     end
% end
% Q2 = [[ var ident(foo) [
%             var ident(bar) [
%                 var ident(goz) [nop]
%             ]
%         ]
%     ]]
% {ExecuteStack [pairSE(s:Q2 e:env())]}
% {Browse 'COMPLETED'}

%%%%%%%%%%%%% Testing bind (Question 3 and 4(a))
% local Foo in
%     local Bar in
%         Foo = Bar
%         Bar = 20
%     end
% end
% Q3 = [[ var ident(foo) [
%             var ident(bar) [
%                 [bind ident(foo) ident(bar)]
%                 [bind ident(bar) literal(20)]
%             ]
%         ]
%     ]]
% {ExecuteStack [pairSE(s:Q3 e:env())]}
% {Browse 'COMPLETED'}

%%%%%%%%%%%%% Testing bind on records (Question 4(b))
% local Foo in
%     local Gamma in 
%         Foo = 1
%         Gamma = 2
%         local Bar in
%             Bar = don(fooval:Foo gammval:Gamma)
%         end
%     end
% end
% Q4 = [[ var ident(foo) [
%             var ident(gamma) [
%                 [bind ident(foo) literal(1)]
%                 [bind ident(gamma) literal(2)]
%                 [ var ident(bar) [
%                     [bind ident(bar) [
%                             record literal(don) [
%                                 [literal(fooval) ident(foo)]
%                                 [literal(gammaval) ident(gamma)]
%                             ]
%                         ]
%                     ]
%                     ]
%                 ]
%             ]
%         ]
%     ]]

%%%%%%%%%%%%%%% Testing Binding to a proc (Q4c).
% local FreeVar Copy A B in
%     proc {Copy X Y}
%         X=Y
%         X = FreeVar
%     end
%     {Copy B A}
%     skip
% end

% Q4c = [[var ident(freeVar)
%                 [var ident(copy)
%                   [var ident(a)
%                      [var ident(b)
%                         [[bind ident(copy) [procedure [ident(x) ident(y)] [
%                             [bind ident(x) ident(y)]
%                             [bind ident(x) ident(freeVar)]
%                         ]]]
%                          [apply ident(copy) ident(b) ident(a)]
%                          [nop]]]]]]]

%%%%%%%%%%%%%%%%%%%%%%% Test pattern matching (Q5)
% local Foo in
%     local Bar in
%         local Baz in
%             Foo = Bar
%             Bar = bruh(code: 21)
%             case Foo of bruh(code: BindedTo21) then
%                 Baz = BindedTo21
%             else Baz = 'f' end
%         end
%     end
% end

% Q5match = [[var ident(foo)
%     [var ident(bar)
%         [var ident(baz)
%             [[bind ident(foo) ident(bar)]
%             [bind ident(bar) [record literal(bruh) [[literal(code) literal(21)]]]]
%             [match ident(foo) [record literal(bruh) [[literal(code) ident(bindedTo21)]]]
%                 [bind ident(baz) ident(bindedTo21)] %If match successful
%                 [bind ident(baz) literal(f)]]  %If match unsuccessful
%             [nop]
%             ]
%     ]]]]

% Q5notMatch = [[var ident(foo)
%     [var ident(bar)
%         [var ident(baz)
%             [[bind ident(foo) ident(bar)]
%             [bind ident(bar) [record literal(bruh) [[literal(code) literal(21)]]]]
%             [match ident(foo) [record literal(bruh) [[literal(coder) ident(bindedTo21)]]]
%                 [bind ident(baz) ident(bindedTo21)] %If match successful
%                 [bind ident(baz) literal(f)]]  %If match unsuccessful
%             [nop]
%             ]
%     ]]]]

{ExecuteStack [pairSE(s:Q5notMatch e:env())]}
{Browse 'COMPLETED'}
