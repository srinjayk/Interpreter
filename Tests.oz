\insert 'Interpreter.oz'

%%%%%%%%%%%% Testing the stack (Question 1)
% Q1 = [[nop] [nop] [nop] [nop]]

% {ExecuteStack [pairSE(s:Q1 e:env())]}
% {Browse 'COMPLETED'}


%%%%%%%%%%%% Testing variable declaration (Question 2)
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
% {ExecuteStack [pairSE(s:Q4 e:env())]}
% {Browse 'COMPLETED'}