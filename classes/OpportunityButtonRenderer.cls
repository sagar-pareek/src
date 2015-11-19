public without sharing class OpportunityButtonRenderer extends OpportunityButtonActionHandler
{
    public OpportunityButtonRenderer(ApexPages.StandardController controller) {}

    public boolean GetCanDemoOpportunity()
    {
        return OpportunityStage.VALUE_PROPOSITION.equals(opportunity.StageName);
    }

    public boolean GetCanProvideProposalAndQuote()
    {
        return OpportunityStage.VALUE_PROPOSITION.equals(opportunity.StageName) ||
            OpportunityStage.DEMO.equals(opportunity.StageName);
    }

    public boolean GetCanMarkAsLost()
    {
        return ! (OpportunityStage.LOST.equals(opportunity.StageName) ||
            OpportunityStage.WON.equals(opportunity.StageName));
    }

    public boolean GetCanMarkAsWon()
    {
        User currentUser = UserDataAccess.GetCurrentUser();
        Set<String>RoleSet = new Set<String>();
        for(UserRole r :[select id from UserRole where name LIKE 'Region Leader%']){
            RoleSet.add(r.id);
        }
        return (currentUser.Profile.Name == 'System Administrator' || RoleSet.contains(currentUser.UserRoleId)) && ( 
            OpportunityStage.REVIEW_AND_NEGOTIATION.equals(opportunity.StageName) ||
            OpportunityStage.PROPOSAL_AND_QUOTE.equals(opportunity.StageName)
        );
    }

    public boolean GetCanReviewAndNegotiate()
    {
        return OpportunityStage.PROPOSAL_AND_QUOTE.equals(opportunity.StageName);
    }

    public boolean GetCanProvideNewQuote()
    {
        return OpportunityStage.PROPOSAL_AND_QUOTE.equals(opportunity.StageName);
    }
    
    public boolean GetCanUpdatePrice()
    {
        return ! (OpportunityStage.WON.equals(opportunity.StageName) || OpportunityStage.LOST.equals(opportunity.StageName));
    }
    
    public boolean GetCanUpdateInstanceDetails()
    {
        return ! (OpportunityStage.WON.equals(opportunity.StageName) || OpportunityStage.LOST.equals(opportunity.StageName));
    }
}