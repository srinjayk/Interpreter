\insert 'Unify.oz'

% This function executes a given stack
declare proc {Execute Stack}
    {Browse Stack}
    % if stack is empty execution is done
    case Stack of nil then skip
    % if top of stack is nop simply pop it out
    [] [nop]|Tail then 
            {Execute Tail}
    [] [var ident(X) S]|Tail then
            local Xbind in
                {Browse 0}
                Xbind = {CreateVariable}
                {Browse 1}
                {Execute S|Tail}
            end
    end
end

declare proc {Debug C}
  if C > @SASCounter then {Browse 'Done'} 
  else {Browse {Dictionary.get SAStore C ?}} {Debug C+1} end
end

% {Execute [[nop] [nop] [nop]]}
% {Browse X}
% {Debug 1}
{Execute [[var ident(x) [nop]]]}
{Debug 0}
