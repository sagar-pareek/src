trigger OnLeadInsert on Lead (after insert)
{
    try
    {
        LeadOwnerAssigner.assignLeadOwner(trigger.new);
    }
    catch(UnderflowException leadOwnerNotAssigned)
    {
        // At this point the lead is not assigned for whatever reason
        // ideally, we should be handling this error but right now 
        // we want the lead owner to be blank and handled manually.
    }
}