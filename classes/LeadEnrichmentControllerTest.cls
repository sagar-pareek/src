@isTest
public class LeadEnrichmentControllerTest
{
    public static TestMethod void VerifyLeadEnrichment()
    {
        SObject lead = ObjectMocker.mock('Lead');
        lead.put('Email', 'mail@example.com');
        lead.put('NumberOfEmployees', 39);
        insert lead;

        ApexPages.currentPage().getParameters().put('id', lead.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        LeadEnrichmentController handler = new LeadEnrichmentController(controller);

        handler.industry = handler.GetListOfIndustries().get(0).getValue();
        PageReference response = handler.EnrichLead();

        System.assert(response.getRedirect());
    }	
}