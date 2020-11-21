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

proc {BindValueToKeyInSAS Key Value}
    case {Dictionary.get SAStore Key} of
        unbound then {Dictionary.put SAStore Key Value}
        [] ref(RefKey) then {BindRefToKeyInSAS RefKey Value}
        [] X then if X==Value then skip else {Raise assignedToAnotherValue(Key Value X)} end
    end
end

proc {BindRefToKeyInSAS Key Ref}
    case {Dictionary.get SAStore Key} of
        unbound then {Dictionary.put SAStore Key ref(Ref)}
        [] ref(X) then {BindRefToKeyInSAS X Ref}
        [] Value then {BindValueToKeyInSAS Ref Value}
    end
end

fun {RetrieveFromSAS Key}
    case {Dictionary.get SAStore Key} of
        unbound then equivalence(Key)
        [] ref(RefKey) then {RetrieveFromSAS RefKey}
        [] Val then Val
    end
end
