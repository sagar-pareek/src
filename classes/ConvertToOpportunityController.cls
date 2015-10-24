public without sharing class ConvertToOpportunityController extends LeadFlowButtonHandler
{    
    public Opportunity opportunity { get; set; }
    public List <SelectOption> allCompetitors { get; set; }
    public List <String> opportunityCompetitors { get; set; }

    public ConvertToOpportunityController(ApexPages.StandardController controller)
    {
        super(controller);
        opportunity = new Opportunity();
   		opportunity.CloseDate = Date.today().addDays(30);
        allCompetitors = GetListOfCompetitors();
    }

    public PageReference ConvertToOpportunity()
    {
		Database.LeadConvert converter = new Database.LeadConvert();

		converter.setLeadId(lead.Id);
		converter.setConvertedStatus(LeadStatus.CONVERTED);
		converter.setDoNotCreateOpportunity(false);
		Database.Leadconvertresult conversion = Database.convertLead(converter);
        if(Test.isRunningTest()){
        	opportunity.id = conversion.getOpportunityId();
        }
		Id opportunityId = conversion.getOpportunityId();
		Opportunity newOpportunity = OpportunityDataAccess.GetOpportunityById(opportunityId);
        
		newOpportunity.StageName   = OpportunityStage.VALUE_PROPOSITION;
		newOpportunity.Amount      = opportunity.Amount;
		newOpportunity.CloseDate   = opportunity.CloseDate;
        newOpportunity.Type        = opportunity.Type;
        newOpportunity.Plan__c     = opportunity.Plan__c;
        newOpportunity.Product__c  = opportunity.Product__c;

		update newOpportunity;
        
        SetOpportunityCompetitors(newOpportunity, opportunityCompetitors);

        return Util.RedirectTo(GetLeadId());
    }
    
    public List <SelectOption> GetListOfCompetitors()
    {
        return Util.GetPicklistValues(new OpportunityCompetitor(), 'CompetitorName');
    }
    
    public void SetOpportunityCompetitors(Opportunity opportunity, List <String> competitors)
    {
        List <OpportunityCompetitor> opportunityCompetitors = new List <OpportunityCompetitor> ();
        
        for(String competitorName : competitors)
        {
            OpportunityCompetitor competitor = new OpportunityCompetitor();
            competitor.CompetitorName = competitorName;
            competitor.OpportunityId = opportunity.Id;
            opportunityCompetitors.add(competitor);
        }
        
        insert opportunityCompetitors;
    }
}