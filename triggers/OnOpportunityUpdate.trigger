trigger OnOpportunityUpdate on Opportunity (after update)
{
    // Webhook sent out on After Insert and After Update events.
    // Only trigger the hook if the environment is production or testing and system
    // is not in batch mode, which might be cause by this same hook if it tries to update a lead
    if(!Test.isRunningTest()){
        if ((Environment.IsProduction() || Environment.IsTest()) && ( ! system.isBatch() && ! system.isFuture()))
        {
            String url = 'https://my.kayako.com/Backend/SFWebhookListener/Handle';
    
            String content = Webhook.AsJson(Trigger.new, Trigger.old);
    
            Webhook.SendRequest(url, content);
        }
        
        NotificationEvents.OpportunityAmountManipulation(Trigger.old, Trigger.new);
    }
}