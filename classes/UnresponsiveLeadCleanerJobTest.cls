@IsTest(SeeAllData = true)
public class UnresponsiveLeadCleanerJobTest 
{
	public static TestMethod void CleanOldUnresponsiveLeads()
    {
        Test.setMock(HttpCalloutMock.class, new WebhookTest());

        SObject lead = ObjectMocker.mock('Lead');
        lead.put('Status', LeadStatus.UNRESPONSIVE);
        lead.put('StatusToUnresponsiveDate__c', Date.today().addMonths(-3));
        lead.put('Email', 'unresponsive@kayako.test');
        
        insert lead;
        
		UnresponsiveLeadCleanerJob job = new UnresponsiveLeadCleanerJob();
        SchedulableContext ctx = null;
        job.execute(ctx);
        
        Lead updatedLead = [SELECT Id, Status, Stage__c, 
                            StageToSRLDate__c, StatusToNurtureDate__c, StatusLastUpdatedDate__c 
                            FROM Lead WHERE Id = :lead.Id LIMIT 1];
        
        System.assertEquals(LeadStatus.NURTURE, updatedLead.Status);
        System.assertEquals(LeadStage.SRL, updatedLead.Stage__c);
        System.assertEquals(Date.today(), updatedLead.StageToSRLDate__c);
        System.assertEquals(Date.today(), updatedLead.StatusToNurtureDate__c);
        System.assertEquals(Date.today(), updatedLead.StatusLastUpdatedDate__c);
    }
}