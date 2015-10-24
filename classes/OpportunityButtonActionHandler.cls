public without sharing abstract class OpportunityButtonActionHandler 
{
    protected Opportunity opportunity;
    
    public String lostReason {get; set;}

    public OpportunityButtonActionHandler()
    {
        opportunity = OpportunityDataAccess.GetOpportunityById(getOpportunityId());
    }

    protected Id getOpportunityId()
    {
        return ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference DemoOpportunity()
    {
        opportunity.StageName = OpportunityStage.DEMO;
        opportunity.StageToDemoDate__c = Date.today();

        update opportunity;

        return Util.RedirectTo(getOpportunityId());
    }

    public PageReference ProvideProposalAndQuote()
    {
        opportunity.StageName = OpportunityStage.PROPOSAL_AND_QUOTE;
        opportunity.StageToProposalDate__c = Date.today();

        update opportunity;

        return Util.RedirectTo(getOpportunityId());
    }

    public PageReference MarkAsLost()
    {
        opportunity.StageName = OpportunityStage.LOST;
        opportunity.LostDate__c = Date.today();
        opportunity.CloseDate = Date.today();
        opportunity.ClosedBy__c = 'Agent';
        opportunity.LostReason__c = lostReason;

        update opportunity;

        return Util.RedirectTo(getOpportunityId());
    }

    public PageReference MarkAsWon()
    {
        opportunity.StageName = OpportunityStage.WON;
        opportunity.WonDate__c = Date.today();
        opportunity.CloseDate = Date.today();
		opportunity.ClosedBy__c = 'Agent';

        update opportunity;

        return Util.RedirectTo(getOpportunityId());
    }

    public PageReference ReviewAndNegotiate()
    {
        opportunity.StageName = OpportunityStage.REVIEW_AND_NEGOTIATION;
        Opportunity.StageToNegotiationDate__c = Date.today();

        update opportunity;

        return Util.RedirectTo(getOpportunityId());
    }
    
    public List <SelectOption> GetLostReasonList()
    {
        return Util.GetPicklistValues(opportunity, 'LostReason__c');
    }
}