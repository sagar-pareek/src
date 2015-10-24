public without sharing class OpportunityInstanceDetailsController extends OpportunityButtonActionHandler
{   
    public Opportunity opportunityValue { get; set; }

    public OpportunityInstanceDetailsController(ApexPages.StandardController controller)
    {
        opportunityValue = opportunity;

        if(opportunityValue.KA_TrialExpiryDate__c == null)
        {
            opportunityValue.KA_TrialExpiryDate__c = DateTime.now();
        }
    }

    public PageReference UpdateInstance()
    {
        opportunity.KA_TrialExpiryDate__c = opportunityValue.KA_TrialExpiryDate__c;
        opportunity.Plan__c = opportunityValue.Plan__c;
        opportunity.Product__c = opportunityValue.Product__c;
        
        update opportunity;

        return Util.RedirectTo(GetOpportunityId());
    }
}