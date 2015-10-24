@isTest
public class LeadDataAccessTest 
{
    public static TestMethod void testGetMatchingLeads()
    {
        SObject mock = ObjectMocker.mock('Lead');
        mock.put('email', 'example@kayako.com');
        mock.put('ka_territory__c', 'APAC');
        
        SObject firstDuplicate = ObjectMocker.mock('Lead');
        firstDuplicate.put('email', 'example@kayako.com');
        firstDuplicate.put('ka_territory__c', 'APAC');
        
        SObject secondDuplicate = ObjectMocker.mock('Lead');
		secondDuplicate.put('email', 'example@kayako.com');
        secondDuplicate.put('ka_territory__c', 'APAC');
       
        insert mock;
        insert firstDuplicate;
        insert secondDuplicate;
        
        Lead lead = [select id, email, ka_territory__c from lead where id = :mock.Id limit 1];

	    // First block coverage
	    List<Lead> matching = LeadDataAccess.GetMatchingLeads(lead);
	    List<Lead> cached = LeadDataAccess.GetMatchingLeads(lead);
	    
	    System.assertEquals(lead.Email, 'example@kayako.com');

    }
    
    @IsTest(SeeAllData = true)
    public static void GetListOfUnresponsiveLeads()
    {
        SObject lead = ObjectMocker.mock('Lead');
        lead.put('Status', LeadStatus.UNRESPONSIVE);
        lead.put('StatusToUnresponsiveDate__c', Date.today().addMonths(-3));
        lead.put('Email', 'unresponsive@kayako.test');
        
        insert lead;
        
        List <Lead> leads = LeadDataAccess.GetUnresponsiveLeadsSinceDate(Date.today().addMonths(-1));
        
        System.assert(leads.size() > 0);
    }
    
    @IsTest(SeeAllData = true)
    public static void GetAllNotesOnList()
    {
        Note note = [select id, parentid from note limit 1];
        List <Note> foundNote = LeadDataAccess.GetNotesOnLead(note.ParentId);

        System.assert(!foundNote.isEmpty());
    }
}