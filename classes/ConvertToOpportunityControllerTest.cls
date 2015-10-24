@isTest
public class ConvertToOpportunityControllerTest
{
    public static TestMethod void ConvertToOpportunityTest()
    {
        Test.setMock(HttpCalloutMock.class, new WebhookTest());

        SObject lead = ObjectMocker.mock('Lead');
        lead.put('Email', 'mail@example.com');
        lead.put('Stage__c','Qualified');
        insert lead;

        ApexPages.currentPage().getParameters().put('id', lead.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        ConvertToOpportunityController handler = new ConvertToOpportunityController(controller);
        
        handler.opportunity.Amount     = 33.5;
        handler.opportunity.Type       = Util.GetPicklistValues(handler.opportunity, 'Type').get(0).getValue();
        handler.opportunity.Plan__c    = Util.GetPicklistValues(handler.opportunity, 'Plan__c').get(0).getValue();
        handler.opportunity.Product__c = Util.GetPicklistValues(handler.opportunity, 'Product__c').get(0).getValue();
		handler.opportunityCompetitors = new List <String> ();
        
        
        PageReference response = handler.ConvertToOpportunity();

        Lead refreshedLead = [SELECT Id, Email, IsConverted, Status 
                    FROM Lead WHERE Id = :lead.Id LIMIT 1];

        System.assert(refreshedLead.IsConverted);
        System.assert(refreshedLead.Status == LeadStatus.CONVERTED);
        
        List<String>compList = new List<String>();
        complist.add('firstComp');
        
        handler.SetOpportunityCompetitors(handler.opportunity,compList);
    }
}