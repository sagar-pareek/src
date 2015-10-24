public without sharing class UpdateOpportunityController extends OpportunityButtonActionHandler 
{
    public Opportunity opportunityValue { get; set; }
    
    public UpdateOpportunityController(ApexPages.StandardController controller)
    {
        opportunityValue = opportunity;
    }
    
    public PageReference UpdatePrice()
    {
        update opportunityValue;
        
        return Util.RedirectTo(GetOpportunityId());
    }
}