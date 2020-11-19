% SAS = Single-Assignment Store is a dictionary
declare SAStore SASCounter
SAStore = {Dictionary.new}
{NewCell 0 ?SASCounter}

% Add a new variable to SAS
% return its name
declare fun {CreateVariable}
    local C in
        C = @SASCounter
        SASCounter := @SASCounter + 1
        {Dictionary.put SAStore C unbound}
        C
    end
end

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

% {Execute [[nop] [nop] [nop]]}
% {Browse X}
% {Debug 1}
{Execute [[var ident(x) [nop]]]}
{Debug 0}

declare proc {Debug 0}
  if C > @SASCounter then {Browse 'Done'} 
  else {Browse {Dictionary.get SAStore C ?}} {Debug C+1} end
end
